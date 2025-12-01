import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

import 'package:shafeea/shared/widgets/avatar.dart';

import '../../../../../shared/widgets/recitation_mode_sidebar.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/ui/widgets/log_out_dialog.dart';
import '../../../../settings/presentation/screens/settings_screen.dart';

// import '../../../../../core/constants/app_colors.dart';

class TecherDashboard extends StatefulWidget {
  const TecherDashboard({super.key});

  @override
  State<TecherDashboard> createState() => _TecherDashboardState();
}

class _TecherDashboardState extends State<TecherDashboard> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_active_outlined, size: 30),
              onPressed: () {},
            ),
          ],
        ),

        drawer: RecitationModeSideBar(
          title: "مرحباً، عمران",
          avatar: Avatar(size: Size(100, 100)),
          items: [
            CustomModeIconButton(
              icon: Icons.person,
              label: "ملفي الشخصي",
              isSelected: false,
              onTap: () {
                context.push('/profile/1');
              },
            ),
            CustomModeIconButton(
              icon: Icons.settings,
              label: "الإعدادات",
              isSelected: false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SettingsScreen();
                    },
                  ),
                );
              },
            ),
            CustomModeIconButton(
              icon: Icons.logout,
              label: "تسجيل الخروج",
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),

        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(child: Center()),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const LogoutConfirmationDialog(),
      ),
    );
  }
}
