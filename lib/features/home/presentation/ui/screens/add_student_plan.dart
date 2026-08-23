import 'package:shafeea_student/core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shafeea/shared/themes/app_theme.dart';
import 'package:shafeea/core/models/report_frequency.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/core/models/tracking_units.dart';
import 'package:shafeea/shared/widgets/custom_text_field.dart';
import '../../../domain/entities/follow_up_plan_entity.dart';

class StudentsPlanForm extends StatefulWidget {
  final formKey = GlobalKey<FormState>();
  final FollowUpPlanEntity? initialPlan;

  final TextEditingController studyPlanType = TextEditingController(text: AppStrings.str_student_6_c2da);

  final Map<TrackingType, TextEditingController> unitTypeControllers = {
    TrackingType.memorization: TextEditingController(text: AppStrings.str_student_49_b23e),
    TrackingType.review: TextEditingController(text: AppStrings.str_student_49_b23e),
    TrackingType.recitation: TextEditingController(text: AppStrings.str_student_49_b23e),
  };
  final Map<TrackingType, TextEditingController> quantityControllers = {
    TrackingType.memorization: TextEditingController(),
    TrackingType.review: TextEditingController(),
    TrackingType.recitation: TextEditingController(),
  };

  StudentsPlanForm({this.initialPlan, super.key}) {
    if (initialPlan != null) {
      studyPlanType.text = initialPlan!.frequency.labelAr;
      for (final detail in initialPlan!.details) {
        unitTypeControllers[detail.type]?.text = detail.unit.labelAr;
        quantityControllers[detail.type]?.text = detail.amount.toString();
      }
    }
  }

  @override
  State<StudentsPlanForm> createState() => _StudentsPlanFormState();
}

class _StudentsPlanFormState extends State<StudentsPlanForm> {
  // Widget داخل الـ build

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.str_student_rem_169_5a42,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightCream87,
            ),
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            widget.studyPlanType,
            AppStrings.str_student_rem_170_2434,
            Frequency.values.map((element) => element.labelAr).toList(),
          ),
          ...TrackingType.values.toList().map(
            (type) => Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    "إعدادات ال${type.labelAr}",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightCream70,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        widget.unitTypeControllers[type]!,
                        "وحدة ال${type.labelAr}",
                        TrackingUnitTyps.values
                            .map((element) => element.labelAr)
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: widget.quantityControllers[type]!,
                        prefixIcon: Icons.format_list_numbered,
                        label: AppStrings.str_student_rem_102_6f0d,
                        keyboardType: TextInputType.number,
                        padding: EdgeInsets.only(bottom: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        style: GoogleFonts.cairo(color: AppColors.lightCream70),
        borderRadius: BorderRadius.circular(14),
        value: controller.text.trim(),
        dropdownColor: AppColors.mediumDark,

        items: options
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: GoogleFonts.cairo(
                    color: AppColors.lightCream70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) => setState(() => controller.text = val ?? AppStrings.str_student_49_b23e),
        onSaved: (val) => controller.text = val ?? AppStrings.str_student_49_b23e,
        padding: EdgeInsets.all(0),
        decoration: InputDecoration(
          fillColor: AppColors.lightCream12,
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: AppColors.lightCream70),
        ),
      ),
    );
  }
}
