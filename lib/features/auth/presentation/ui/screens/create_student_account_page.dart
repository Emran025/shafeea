import 'package:shafeea/core/l10n/app_strings.dart' as L10nStrings;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafeea/core/models/education_level.dart';
import 'package:shafeea/core/models/gender.dart';

import 'package:shafeea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shafeea/features/auth/domain/entities/student_applicant.dart';
import 'package:shafeea/shared/widgets/school_picker_dialog.dart';

import 'package:shafeea/shared/themes/app_theme.dart';
import 'package:shafeea/core/constants/countries_names.dart';
import 'package:shafeea/shared/func/date_format.dart';
import 'package:shafeea/shared/widgets/country_picker_dialog.dart';
import 'package:shafeea/shared/widgets/custom_text_field.dart';
import 'package:shafeea/shared/widgets/phone_zone.dart';
import 'package:shafeea/shared/widgets/pick_date.dart';
import 'package:shafeea/shared/widgets/pick_time.dart';
import '../../../../../core/models/countery_model.dart';
import '../../../../daily_tracking/presentation/pages/quran_memorization_picker.dart';

class CreateStudentAccountPage extends StatefulWidget {
  CreateStudentAccountPage({super.key});

  @override
  State<CreateStudentAccountPage> createState() =>
      _CreateStudentAccountPageState();
}

class _CreateStudentAccountPageState extends State<CreateStudentAccountPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ─────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _confirmPassCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _phoneZoneCtrl;
  late final TextEditingController _whatsAppPhoneCtrl;
  late final TextEditingController _whatsAppZoneCtrl;
  late final TextEditingController _qualificationCtrl;
  late final TextEditingController _memorizationCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _residenceCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _schoolCtrl;

  // ── State ────────────────────────────────────────────────────────
  late CountryModel selectedPhoneZone;
  late CountryModel selectedWhatsAppZone;
  late CountryModel selectedCountry;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _usernameManuallyEdited = false;
  Timer? _usernameDebounce;

  /// يُخزّن التاريخ الأصلي لإرساله بتنسيق ISO 8601 إلى الـ API
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initCountries();

    _animCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();

    _nameCtrl.addListener(_onNameChanged);
    _usernameCtrl.addListener(_onUsernameChanged);

    // Fetch available schools for the registration dropdown.
    context.read<AuthBloc>().add(FetchSchoolsRequested());
  }

  void _initControllers() {
    _nameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _genderCtrl = TextEditingController(text: 'Male');
    _birthDateCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _phoneZoneCtrl = TextEditingController();
    _whatsAppPhoneCtrl = TextEditingController();
    _whatsAppZoneCtrl = TextEditingController();
    _qualificationCtrl = TextEditingController(
      text: EducationLevel.noFormalEducation.labelAr,
    );
    _memorizationCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _residenceCtrl = TextEditingController();
    _timeCtrl = TextEditingController();
    _schoolCtrl = TextEditingController();
  }

  void _initCountries() {
    selectedPhoneZone = countries.firstWhere(
      (c) => c.countryCallingCode == 'YE',
      orElse: () => countries.first,
    );
    selectedWhatsAppZone = selectedPhoneZone;
    selectedCountry = selectedPhoneZone;
    _phoneZoneCtrl.text = selectedPhoneZone.countryCallingCode;
    _whatsAppZoneCtrl.text = selectedWhatsAppZone.countryCallingCode;
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _nameCtrl.removeListener(_onNameChanged);
    _usernameCtrl.removeListener(_onUsernameChanged);
    _animCtrl.dispose();
    for (final c in [
      _nameCtrl,
      _usernameCtrl,
      _emailCtrl,
      _passCtrl,
      _confirmPassCtrl,
      _bioCtrl,
      _genderCtrl,
      _birthDateCtrl,
      _phoneCtrl,
      _phoneZoneCtrl,
      _whatsAppPhoneCtrl,
      _whatsAppZoneCtrl,
      _qualificationCtrl,
      _memorizationCtrl,
      _countryCtrl,
      _residenceCtrl,
      _timeCtrl,
      _schoolCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : Color(0xFFF2F1EC),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) => _handleBlocListener(ctx, state),
        builder: (ctx, state) {
          final isChecking =
              state.usernameCheckStatus == UsernameCheckStatus.loading;
          final isAvailable = state.usernameCheck;
          final checkStatus = state.usernameCheckStatus;

          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 190,
                pinned: true,
                floating: false,
                elevation: 0,
                backgroundColor: isDark
                    ? AppColors.mediumDark
                    : AppColors.accent,
                iconTheme: IconThemeData(color: Colors.white),
                title: Text(
                  L10nStrings.AppStrings.createNewStudentAccount,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _buildHeroHeader(isDark),
                ),
              ),
            ],
            body: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSection(
                          context,
                          icon: Icons.person_rounded,
                          title: L10nStrings.AppStrings.basicInformation,
                          children: [
                            CustomTextField(
                              controller: _nameCtrl,
                              prefixIcon: Icons.badge_outlined,
                              label: L10nStrings.AppStrings.threePartName,
                              keyboardType: TextInputType.name,
                            ),
                            CustomTextField(
                              controller: _bioCtrl,
                              prefixIcon: Icons.info_outline_rounded,
                              label: L10nStrings.AppStrings.briefBio,
                              keyboardType: TextInputType.multiline,
                            ),
                          ],
                        ),
                        _buildSection(
                          context,
                          icon: Icons.lock_person_rounded,
                          title: L10nStrings.AppStrings.loginDetails,
                          children: [
                            CustomTextField(
                              controller: _emailCtrl,
                              prefixIcon: Icons.alternate_email_rounded,
                              label: L10nStrings.AppStrings.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            CustomTextField(
                              controller: _usernameCtrl,
                              prefixIcon: Icons.person_outline_rounded,
                              label: L10nStrings.AppStrings.username,
                              keyboardType: TextInputType.text,
                              suffixIcon: _buildUsernameStatusIcon(
                                isChecking,
                                isAvailable,
                              ),
                              validator: (val) {
                                final value = val?.trim() ?? '';
                                if (value.isEmpty) {
                                  return L10nStrings.AppStrings.usernameRequired;
                                }
                                if (checkStatus == UsernameCheckStatus.loaded &&
                                    !isAvailable) {
                                  return L10nStrings.AppStrings.usernameAlreadyTaken;
                                }
                                return null;
                              },
                            ),
                            if (_usernameCtrl.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _usernameStatusText(
                                      isChecking,
                                      isAvailable,
                                      checkStatus,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: _usernameStatusColor(
                                        context,
                                        isAvailable,
                                        checkStatus,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            CustomTextField(
                              controller: _passCtrl,
                              prefixIcon: Icons.lock_outline_rounded,
                              label: L10nStrings.AppStrings.password,
                              isPassword: true,
                            ),
                            CustomTextField(
                              controller: _confirmPassCtrl,
                              prefixIcon: Icons.lock_reset_rounded,
                              label: L10nStrings.AppStrings.confirmPassword,
                              isPassword: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return L10nStrings.AppStrings.confirmPasswordRequired;
                                }
                                if (val != _passCtrl.text) {
                                  return L10nStrings.AppStrings.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            _buildSchoolField(context, state),
                          ],
                        ),
                        _buildSection(
                          context,
                          icon: Icons.face_rounded,
                          title: L10nStrings.AppStrings.personalInformation,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildGenderDropdown(context)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: CustomDatePicker(
                                    controller: _birthDateCtrl,
                                    icon: Icons.cake_outlined,
                                    label: L10nStrings.AppStrings.dateOfBirth,
                                    onDateSelected: (d) {
                                      _selectedBirthDate = d;
                                      _birthDateCtrl.text = formatDate(d);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            CustomTextField(
                              controller: _countryCtrl,
                              prefixIcon: Icons.flag_outlined,
                              label: L10nStrings.AppStrings.placeOfBirth,
                              readOnly: true,
                              onTap: (ctrl, _) => _showCountryDialog(ctrl),
                            ),
                            CustomTextField(
                              controller: _residenceCtrl,
                              prefixIcon: Icons.location_city_rounded,
                              label: L10nStrings.AppStrings.countryOfResidence,
                              readOnly: true,
                              onTap: (ctrl, _) => _showCountryDialog(ctrl),
                            ),
                          ],
                        ),
                        _buildSection(
                          context,
                          icon: Icons.contact_phone_rounded,
                          title: L10nStrings.AppStrings.contactTitle,
                          children: [
                            PhoneZoneForm(
                              phoneController: _phoneCtrl,
                              zoneController: _phoneZoneCtrl,
                              initialCountry: selectedPhoneZone,
                              label: L10nStrings.AppStrings.phoneNumber,
                              onCountryChanged: () => _updatePhoneZone(
                                _phoneZoneCtrl,
                                (c) => selectedPhoneZone = c,
                              ),
                            ),
                            PhoneZoneForm(
                              phoneController: _whatsAppPhoneCtrl,
                              zoneController: _whatsAppZoneCtrl,
                              initialCountry: selectedWhatsAppZone,
                              label: L10nStrings.AppStrings.whatsapp,
                              onCountryChanged: () => _updatePhoneZone(
                                _whatsAppZoneCtrl,
                                (c) => selectedWhatsAppZone = c,
                              ),
                            ),
                            CustomTimePicker(
                              controller: _timeCtrl,
                              icon: Icons.access_time_filled_rounded,
                              label: L10nStrings.AppStrings.preferredContactTime,
                              onTimeSelected: (t) =>
                                  _timeCtrl.text = t.format(context),
                            ),
                          ],
                        ),
                        _buildSection(
                          context,
                          icon: Icons.menu_book_rounded,
                          title: L10nStrings.AppStrings.educationInfo,
                          children: [
                            _buildDropdown(
                              _qualificationCtrl,
                              L10nStrings.AppStrings.educationTypeQualification,
                              [
                                ...(EducationLevel.values
                                    .map((e) => e.labelAr)
                                    .toList()),
                              ],
                            ),
                            CustomTextField(
                              controller: _memorizationCtrl,
                              prefixIcon: Icons.calendar_month,
                              keyboardType: TextInputType.number,
                              label: L10nStrings.AppStrings.previousMemorizationPages,
                              onTap: _openMemorizationPicker,
                              readOnly: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (state.status == LogInStatus.loading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                              strokeWidth: 2.5,
                            ),
                          )
                        else
                          _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  WIDGETS
  // ════════════════════════════════════════════════════════════════

  /// Gradient hero behind the collapsed SliverAppBar
  Widget _buildHeroHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkBackground, AppColors.mediumDark]
              : [AppColors.mediumDark, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // decorative blobs
          Positioned(top: -35, left: -35, child: _blob(130, 0.05)),
          Positioned(bottom: -25, right: -25, child: _blob(110, 0.07)),
          Positioned(top: 40, right: 60, child: _blob(50, 0.04)),
          // content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 36),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  L10nStrings.AppStrings.joinShafaaPlatform,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  L10nStrings.AppStrings.enterDetailsToCreateAccount,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Opens the Quran memorization range picker and writes the returned
  // signed page count into the "المستوى في الحفظ" field instead of allowing
  // manual typing.
  void _openMemorizationPicker(
    TextEditingController memorizationLevel,
    String title,
  ) {
    showQuranMemorizationPickerDialog(
      context: context,
      onConfirm: (fromPage, toPage, fromInfo, toInfo, signedPages) {
        setState(() {
          memorizationLevel.text = "$signedPages";
        });
      },
    );
  }

  Widget _blob(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );

  /// Styled card container for each form section
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mediumDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(isDark ? 0.12 : 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 18,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(colorScheme, icon, title),
            SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ColorScheme cs, IconData icon, String title) {
    return Row(
      children: [
        // accent bar
        Container(
          width: 3.5,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary, cs.primary.withOpacity(0.25)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 10),
        // icon badge
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: cs.primary),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: cs.onSurface.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _genderCtrl.text.isEmpty ? 'Male' : _genderCtrl.text,
        isDense: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colorScheme.onSurface.withOpacity(0.5),
          size: 22,
        ),
        dropdownColor: isDark ? AppColors.mediumDark : Colors.white,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: L10nStrings.AppStrings.genderLabel,
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.55),
            fontFamily: 'Cairo',
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.wc_rounded,
            color: colorScheme.primary.withOpacity(0.75),
            size: 20,
          ),
          filled: true,
          fillColor: isDark
              ? colorScheme.onSurface.withOpacity(0.07)
              : colorScheme.primary.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
          ),
        ),
        items: [
          DropdownMenuItem(
            value: 'Male',
            child: Text(
              L10nStrings.AppStrings.genderMale,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: colorScheme.onSurface,
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'Female',
            child: Text(
              L10nStrings.AppStrings.genderFemale,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
        onChanged: (val) {
          if (val != null) setState(() => _genderCtrl.text = val);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.mediumDark],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.38),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _submitForm,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  L10nStrings.AppStrings.registerAccount,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  LOGIC
  // ════════════════════════════════════════════════════════════════
  void _onNameChanged() {
    if (_usernameManuallyEdited) return;

    final name = _nameCtrl.text.trim();
    context.read<AuthBloc>().add(UsernameRequested(name));
  }

  void _onUsernameChanged() {
    _usernameManuallyEdited = true;
    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(Duration(milliseconds: 500), () {
      final username = _usernameCtrl.text.trim();
      context.read<AuthBloc>().add(UsernameCheckRequested(username));
    });
  }

  Widget? _buildUsernameStatusIcon(bool isChecking, bool isAvailable) {
    if (isChecking) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (isAvailable == true) {
      return Icon(Icons.check_circle, color: AppColors.success);
    }

    if (isAvailable == false) {
      return Icon(Icons.cancel, color: AppColors.error);
    }

    return null;
  }

  String _usernameStatusText(
    bool isChecking,
    bool isAvailable,
    UsernameCheckStatus status,
  ) {
    if (isChecking) return L10nStrings.AppStrings.checkingAvailability;
    if (status == UsernameCheckStatus.loaded) {
      return isAvailable ? L10nStrings.AppStrings.usernameAvailable : L10nStrings.AppStrings.usernameAlreadyTaken;
    }
    return '';
  }

  Color _usernameStatusColor(
    BuildContext context,
    bool isAvailable,
    UsernameCheckStatus status,
  ) {
    if (status == UsernameCheckStatus.loaded) {
      return isAvailable ? AppColors.success : AppColors.error;
    }
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  }

  void _handleBlocListener(BuildContext context, AuthState state) {
    if (state.status == LogInStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.successEntity?.message ??
                L10nStrings.AppStrings.accountCreatedPleaseLogin,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
      Navigator.pop(context);
    } else if (state.status == LogInStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.failure?.message ?? L10nStrings.AppStrings.registrationError,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    }

    // ✅ معالجة اقتراح اسم المستخدم وتحديث الحقل إذا لم يعدل المستخدم يدوياً
    if (state.usernameSuggestionStatus == UsernameSuggestionStatus.loaded &&
        !_usernameManuallyEdited) {
      final suggestion = state.usernameSuggestion;
      if (suggestion.isNotEmpty && _usernameCtrl.text != suggestion) {
        _usernameCtrl.text = suggestion;
      }
    }
    // يمكن إضافة معالجة للأخطاء إذا أردت (اختياري)
    if (state.usernameSuggestionStatus == UsernameSuggestionStatus.failure ||
        state.usernameCheckStatus == UsernameCheckStatus.failure) {
      // مثلاً عرض SnackBar أو تجاهل
    }
  }

  void _updatePhoneZone(
    TextEditingController controller,
    void Function(CountryModel) onUpdate,
  ) {
    setState(() {
      try {
        final country = countries.firstWhere(
          (x) => x.countryCallingCode == controller.text,
        );
        onUpdate(country);
      } catch (_) {}
    });
  }

  void _showCountryDialog(TextEditingController controller) {
    showDialog(
      context: context,
      builder: (_) => CountryPickerDialog(
        initialCountry: selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            selectedCountry = country;
            controller.text = country.arabicName;
          });
        },
        isCollingCode: false,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final selectedSchool = context.read<AuthBloc>().state.selectedSchool;

      final student = StudentApplicantEntity(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        username: _usernameCtrl.text.trim().toLowerCase(),
        password: _passCtrl.text,
        bio: _bioCtrl.text.isNotEmpty ? _bioCtrl.text : L10nStrings.AppStrings.newStudent,
        qualifications: _qualificationCtrl.text,
        memorizationLevel: int.tryParse(_memorizationCtrl.text),
        gender: Gender.fromLabel(_genderCtrl.text),
        birthDate: _selectedBirthDate != null
            ? formatDateForApi(_selectedBirthDate!)
            : _birthDateCtrl.text,
        phone: _phoneCtrl.text,
        phoneZone: _phoneZoneCtrl.text.replaceAll('+', ''),
        whatsapp: _whatsAppPhoneCtrl.text,
        whatsappZone: _whatsAppZoneCtrl.text.replaceAll('+', ''),
        country: _countryCtrl.text,
        residence: _residenceCtrl.text,
        schoolId: selectedSchool?.id,
      );

      context.read<AuthBloc>().add(
        SubmitStudentRegistration(studentApplicant: student),
      );
    }
  }

  /// School selector dropdown — shows a shimmer while loading, the list of
  /// schools once loaded, and a neutral fallback on failure.
  /// Tappable read-only field that opens [SchoolPickerDialog].
  ///
  /// Returns [SizedBox.shrink] when:
  /// - The list is empty (no schools configured on the backend).
  /// - There is exactly one school (it is pre-selected silently by the BLoC).
  /// While still loading it renders a disabled shimmer row instead.
  Widget _buildSchoolField(BuildContext context, AuthState state) {
    // Hide entirely once loaded if there is nothing meaningful to choose from.
    if (state.schoolsStatus == SchoolsStatus.loaded &&
        state.schools.length <= 1) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final isLoading = state.schoolsStatus == SchoolsStatus.loading ||
        state.schoolsStatus == SchoolsStatus.initial;

    // ── Loading shimmer ──────────────────────────────────────────────
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.onSurface.withOpacity(0.07)
                : colorScheme.primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 14),
              Icon(
                Icons.school_outlined,
                color: colorScheme.primary.withOpacity(0.5),
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                L10nStrings.AppStrings.loadingSchools,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.45),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Tappable field ───────────────────────────────────────────────
    return CustomTextField(
      controller: _schoolCtrl,
      prefixIcon: Icons.school_outlined,
      label: L10nStrings.AppStrings.schoolLabel,
      readOnly: true,
      onTap: (_, __) => _showSchoolDialog(state),
    );
  }

  /// Opens the [SchoolPickerDialog], then dispatches [SchoolSelected] and
  /// syncs [_schoolCtrl] with the chosen school name.
  void _showSchoolDialog(AuthState state) {
    showDialog<void>(
      context: context,
      builder: (_) => SchoolPickerDialog(
        schools: state.schools,
        initialSchool: state.selectedSchool,
        onSchoolSelected: (school) {
          context.read<AuthBloc>().add(SchoolSelected(school));
          setState(() {
            _schoolCtrl.text =
                school != null ? school.name : L10nStrings.AppStrings.independentNoSchool;
          });
        },
      ),
    );
  }

  Widget _buildDropdown(
    TextEditingController controller,
    String label,
    List<String> options,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12, left: 14),
      child: DropdownButtonFormField<String>(
        itemHeight: 50,
        style: TextStyle(fontFamily: 'Cairo'),
        borderRadius: BorderRadius.circular(14),
        value: controller.text.trim(),
        dropdownColor: AppColors.mediumDark,
        items: options
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e == "Male"
                      ? L10nStrings.AppStrings.genderMale
                      : e == "Female" || e == "female"
                      ? L10nStrings.AppStrings.genderFemale
                      : e,
                  style: TextStyle(
                    fontFamily: 'Cairo',

                    color: AppColors.lightCream70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) =>
            setState(() => controller.text = val ?? options.first),
        onSaved: (val) => controller.text = val ?? options.first,
        decoration: InputDecoration(
          fillColor: AppColors.lightCream12,
          labelText: label,
          labelStyle: TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}
