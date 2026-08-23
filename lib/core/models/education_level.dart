import 'package:shafeea_student/core/l10n/app_strings.dart';
enum EducationLevel {
  unknown(
    0,
    AppStrings.str_student_23_61ab,
    'Uneducation',
  ),

  noFormalEducation(
    1,
    AppStrings.str_student_24_ccb4,
    'No formal education',
  ),

  primaryEducation(
    2,
    AppStrings.str_student_25_db43,
    'Primary education',
  ),

  lowerSecondaryEducation(
    3,
    AppStrings.str_student_26_8f5f,
    'Lower secondary education',
  ),

  upperSecondaryEducation(
    4,
    AppStrings.str_student_27_be21,
    'Upper secondary education',
  ),

  postsecondaryNonTertiaryEducation(
    5,
    AppStrings.str_student_28_131c,
    'Postsecondary non-tertiary education',
  ),

  shortCycleTertiaryEducation(
    6,
    AppStrings.str_student_29_8970,
    'Short-cycle tertiary education',
  ),

  bachelorsDegree(
    7,
    AppStrings.str_student_30_6d0a,
    "Bachelor's degree",
  ),

  mastersDegree(
    8,
    AppStrings.str_student_31_0542,
    "Master's degree",
  ),

  doctoralDegree(
    9,
    AppStrings.str_student_32_8d0c,
    'Doctoral degree',
  );

  final int id;
  final String labelAr;
  final String label;

  const EducationLevel(
    this.id,
    this.labelAr,
    this.label,
  );

  /// Find an [EducationLevel] by its database ID.
  static EducationLevel fromId(int id) {
    return EducationLevel.values.firstWhere(
      (e) => e.id == id,
      orElse: () => EducationLevel.unknown,
    );
  }

  /// Find an [EducationLevel] by Arabic or English label.
  static EducationLevel fromLabel(String value) {
    final normalized = value.trim().toLowerCase();

    for (final level in EducationLevel.values) {
      if (level.label.toLowerCase() == normalized ||
          level.labelAr == value.trim()) {
        return level;
      }
    }

    return EducationLevel.unknown;
  }
}