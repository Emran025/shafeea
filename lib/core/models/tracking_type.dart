import 'package:shafeea_student/core/l10n/app_strings.dart';
enum TrackingType {
  memorization(1, AppStrings.str_student_42_75f3, "Memorization"),
  review(2, AppStrings.str_student_43_34da, "Review"),
  recitation(3, AppStrings.str_student_44_010c, "Recitation");

  final int id;
  final String labelAr;
  final String label;
  const TrackingType(this.id, this.labelAr, this.label);
  static TrackingType fromId(int id) {
    return TrackingType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => recitation,
    );
  }

  static TrackingType fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'memorization':
      case AppStrings.str_student_42_75f3:
        return TrackingType.memorization;
      case 'review':
      case AppStrings.str_student_43_34da:
        return TrackingType.review;
      default:
        return TrackingType.recitation;
    }
  }
}
