import 'package:shafeea_student/core/l10n/app_strings.dart';
enum ActiveStatus {
  active(1, AppStrings.str_student_17_1f74, "Active"),
  inactive(2, AppStrings.str_student_18_3fd0, "Inactive"),
  pending(3, AppStrings.str_student_19_adc1, "Pending"),
  stopped(4, AppStrings.str_student_20_c033, "Stopped"),
    unknown(0,'UN', "Unknown"),

  waiteing(5, AppStrings.str_student_21_1117, "Waiteing");

  final int id;
  final String labelAr;
  final String label;
  const ActiveStatus(this.id, this.labelAr, this.label);

  static ActiveStatus fromId(int id) {
    return ActiveStatus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => inactive,
    );
  }

  static ActiveStatus fromLabel(String label) {
    switch (label.toLowerCase()) {
      case AppStrings.str_student_17_1f74:
      case 'active':
        return ActiveStatus.active;
      case AppStrings.str_student_18_3fd0:
      case 'inactive':
        return ActiveStatus.inactive;
      case AppStrings.str_student_19_adc1:
      case 'pending':
        return ActiveStatus.pending;
      case AppStrings.str_student_20_c033:
      case 'stopped':
        return ActiveStatus.pending;
      default:
        return ActiveStatus.waiteing;
    }
  }
}



