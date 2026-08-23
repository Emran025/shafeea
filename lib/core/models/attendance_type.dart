import 'package:shafeea_student/core/l10n/app_strings.dart';

enum AttendanceType {

  present(1 , AppStrings.str_student_13_19d1, 'present'),
  absent(2 , AppStrings.str_student_22_123c, 'absent'),
  other( 3, 'UN', 'UN');

  final int id;
  final String labelAr;
  final String label;
  const AttendanceType( this.id,  this.labelAr, this.label);
  static AttendanceType fromId(int id) {
    return AttendanceType.values.firstWhere((e) => e.id == id, orElse: () => absent);
  }  static AttendanceType fromLabel(String label) {
    switch (label.toLowerCase()) {
      case AppStrings.str_student_13_19d1:
      case 'present':
        return AttendanceType.present;
      case AppStrings.str_student_22_123c:
      case 'absent':
        return AttendanceType.absent;
      default:
        return AttendanceType.other;
    }
  }
}
