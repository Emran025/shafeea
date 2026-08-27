import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/themes/app_theme.dart';

class MyCertificatesScreen extends StatefulWidget {
  const MyCertificatesScreen({super.key});

  @override
  State<MyCertificatesScreen> createState() => _MyCertificatesScreenState();
}

class _MyCertificatesScreenState extends State<MyCertificatesScreen> {
  bool _isLoading = true;
  List<dynamic> _certificates = [];

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('https://api.shafeea.com/api/v1/certificates/my-certificates'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _certificates = data['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('فشل في جلب الشهادات');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الرابط')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('شهاداتي', style: GoogleFonts.cairo()),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _certificates.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد شهادات مسجلة باسمك حالياً.',
                    style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _certificates.length,
                  itemBuilder: (context, index) {
                    final cert = _certificates[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              cert['file_url_jpg'] ?? '',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert['batch_name'] ?? 'شهادة',
                                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('تاريخ الإصدار: ${cert['issue_date']}',
                                        style: const TextStyle(color: Colors.grey)),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                          tooltip: 'تنزيل PDF',
                                          onPressed: () => _openUrl(cert['file_url_pdf']),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.verified_user, color: Colors.green),
                                          tooltip: 'صفحة التحقق',
                                          onPressed: () => _openUrl(cert['verify_url']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
