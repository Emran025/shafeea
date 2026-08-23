import 'package:shafeea/core/l10n/app_strings.dart' as L10nStrings;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shafeea/shared/themes/app_theme.dart';
import 'package:uuid/uuid.dart';

import 'package:shafeea/shared/widgets/avatar.dart';

import '../../../../../config/di/injection.dart';
import '../../../../../shared/widgets/recitation_mode_sidebar.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../core/models/active_status.dart';
import '../../../../../core/models/report_frequency.dart';
import '../../../../../core/models/tracking_type.dart';
import '../../../../../core/models/tracking_units.dart';
import '../../../../auth/presentation/ui/widgets/log_out_dialog.dart';
import '../../../../daily_tracking/presentation/bloc/quran_reader_bloc.dart';
import '../../../../daily_tracking/presentation/bloc/tracking_session_bloc.dart';
import '../../../../daily_tracking/presentation/pages/quran_reader_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../settings/presentation/screens/settings_screen.dart';
import '../../../domain/entities/follow_up_plan_entity.dart';
import '../../../domain/entities/plan_detail_entity.dart';
import '../../../domain/entities/plan_for_the_day_entity.dart';
import '../../bloc/student_bloc.dart';
import 'add_student_plan.dart';

// import '../../../../../core/constants/app_colors.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(StudentDetailsFetched());
    context.read<StudentBloc>().add(PlanForTheDayRequested());
  }

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
          title: L10nStrings.AppStrings.helloImranGreeting,
          avatar: Avatar(size: Size(100, 100)),
          items: [
            CustomModeIconButton(
              icon: Icons.person,
              label: L10nStrings.AppStrings.myProfileLabel,
              isSelected: false,
              onTap: () {
                context.push('/profile/1');
              },
            ),
            CustomModeIconButton(
              icon: Icons.menu_book_sharp,
              label: L10nStrings.AppStrings.myDailyPortionLabel,
              isSelected: false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: sl<QuranReaderBloc>()),
                        // Provider for the new session
                        BlocProvider(
                          create: (context) =>
                              sl<TrackingSessionBloc>()..add(SessionStarted()),
                        ),
                      ],
                      child: QuranReaderScreen(),
                    ),
                  ),
                );
              },
            ),
            CustomModeIconButton(
              icon: Icons.settings,
              label: L10nStrings.AppStrings.settingsLabel,
              isSelected: false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return SettingsScreen();
                    },
                  ),
                );
              },
            ),
            CustomModeIconButton(
              icon: Icons.logout,
              label: L10nStrings.AppStrings.logOut,
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
          child: SafeArea(
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                final student = state.selectedStudent?.studentDetailEntity;
                final isDemoMode =
                    student == null || student.status != ActiveStatus.active;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      if (isDemoMode)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  L10nStrings.AppStrings.trialModeUnderReviewMessage,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Latest Alerts - Frosted Glass Effect
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.mediumDark87,
                                AppColors.mediumDark70,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                L10nStrings.AppStrings.latestAlertsTitle,
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                L10nStrings.AppStrings.noNewAlertsMessage,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Plan for the Day Card - Modern Style
                      Expanded(
                        child:
                            state.planForTheDayStatus ==
                                PlanForTheDayStatus.loading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accent,
                                ),
                              )
                            : state.planForTheDayStatus ==
                                  PlanForTheDayStatus.failure
                            ? _buildNoHalaqaCta()
                            : state.planForTheDayStatus ==
                                  PlanForTheDayStatus.success
                            ? ListView(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.mediumDark87,
                                          AppColors.mediumDark70,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              L10nStrings.AppStrings.todaysTasksTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!
                                                  .copyWith(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            IconButton(
                                              tooltip: L10nStrings.AppStrings.configurePlanTooltip,
                                              onPressed: () => _showPlanDialog(
                                                state
                                                    .selectedStudent
                                                    ?.followUpPlan,
                                              ),
                                              icon: Icon(
                                                Icons.edit_calendar_outlined,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        state.planForTheDay != null &&
                                                state
                                                    .planForTheDay!
                                                    .section
                                                    .isNotEmpty
                                            ? Column(
                                                children: state
                                                    .planForTheDay!
                                                    .section
                                                    .map(
                                                      (section) =>
                                                          _buildModernTaskCard(
                                                            section,
                                                          ),
                                                    )
                                                    .toList(),
                                              )
                                            : _buildSetPlanCta(),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Shown when the student has no halqa enrollment yet.
  /// Shown when there is no active halqa enrollment — lets the student
  /// set up a local plan while their account is being reviewed.
  Widget _buildNoHalaqaCta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  L10nStrings.AppStrings.accountUnderReviewSetPlanMessage,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showPlanDialog(null),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent12,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent38),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L10nStrings.AppStrings.startSetUpMemorizationPlanButton,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        L10nStrings.AppStrings.tapHereCreateDailyReviewPlan,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white38,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shown when the student has no plan yet — tapping opens the plan form dialog.
  Widget _buildSetPlanCta() {
    return GestureDetector(
      onTap: () => _showPlanDialog(null),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.accent12,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent38),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent38,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10nStrings.AppStrings.startSetUpMemorizationPlanButton,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    L10nStrings.AppStrings.tapHereCustomizeDailyReviewPlan,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  void _showPlanDialog(FollowUpPlanEntity? currentPlan) {
    final planForm = StudentsPlanForm(initialPlan: currentPlan);
    final bloc = context.read<StudentBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black45,
              insetPadding: const EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_calendar_outlined,
                              color: AppColors.lightCream,
                            ),
                            SizedBox(width: 8),
                            Text(
                              L10nStrings.AppStrings.configureFollowUpPlan,
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightCream,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(height: 2, color: AppColors.accent70),
                        SizedBox(height: 16),
                        planForm,
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.accent70),
                                ),
                                child: Text(
                                  L10nStrings.AppStrings.cancel,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                ),
                                onPressed: () {
                                  if (planForm.formKey.currentState
                                          ?.validate() ??
                                      false) {
                                    planForm.formKey.currentState?.save();

                                    final freq = Frequency.values.firstWhere(
                                      (f) =>
                                          f.labelAr ==
                                          planForm.studyPlanType.text,
                                      orElse: () => Frequency.daily,
                                    );

                                    final details = TrackingType.values.map((
                                      type,
                                    ) {
                                      final unitText =
                                          planForm
                                              .unitTypeControllers[type]
                                              ?.text ??
                                          L10nStrings.AppStrings.unitPage;
                                      final qtyText =
                                          planForm
                                              .quantityControllers[type]
                                              ?.text ??
                                          '0';
                                      final qty = int.tryParse(qtyText) ?? 0;
                                      final unit = TrackingUnitTyps.values
                                          .firstWhere(
                                            (u) => u.labelAr == unitText,
                                            orElse: () => TrackingUnitTyps.page,
                                          );
                                      return PlanDetailEntity(
                                        type: type,
                                        unit: unit,
                                        amount: qty,
                                      );
                                    }).toList();

                                    final existingId =
                                        currentPlan?.planId ?? '';
                                    final updatedPlan = FollowUpPlanEntity(
                                      planId:
                                          existingId.isEmpty ||
                                              existingId == '0'
                                          ? Uuid().v4()
                                          : existingId,
                                      serverPlanId:
                                          existingId.isEmpty ||
                                              existingId == '0'
                                          ? '0'
                                          : existingId,
                                      frequency: freq,
                                      details: details,
                                      createdAt: DateTime.now()
                                          .toIso8601String(),
                                      updatedAt: DateTime.now()
                                          .toIso8601String(),
                                    );

                                    bloc.add(
                                      SaveStudentPlanRequested(updatedPlan),
                                    );
                                    Navigator.pop(dialogContext);
                                  }
                                },
                                child: Text(
                                  L10nStrings.AppStrings.trackingMemorization,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: LogoutConfirmationDialog(),
      ),
    );
  }

  // Modern Task Card Helper
  Widget _buildModernTaskCard(PlanForTheDaySection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumDark70,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(color: AppColors.accent38),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                section.type.labelAr,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white24, height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDetailColumnModern(
                  L10nStrings.AppStrings.fromLabel2,
                  section.fromTrackingUnitId.fromSurahName,
                  section.fromTrackingUnitId.fromPage.toString(),
                  section.fromTrackingUnitId.fromAyah.toString(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDetailColumnModern(
                  L10nStrings.AppStrings.untilLabel,
                  section.toTrackingUnitId.toSurahName,
                  section.toTrackingUnitId.toPage.toString(),
                  section.toTrackingUnitId.toAyah.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumnModern(
    String header,
    String surah,
    String page,
    String ayah,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        _buildDetailRowModern(L10nStrings.AppStrings.surahLabel2, surah),
        _buildDetailRowModern(L10nStrings.AppStrings.pageLabel2, page),
        _buildDetailRowModern(L10nStrings.AppStrings.ayahLabel2, ayah),
      ],
    );
  }

  Widget _buildDetailRowModern(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 8),
      child: Text(
        "$label $value",
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Colors.white60,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
