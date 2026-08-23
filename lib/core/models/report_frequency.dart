import 'package:shafeea_student/core/l10n/app_strings.dart';
enum Frequency {
  daily(1, AppStrings.str_student_6_c2da, "daily" , 1),
  onceAWeek(2, AppStrings.str_student_7_0fcb, "onceAWeek", 7),
  twiceAWeek(3, AppStrings.str_student_8_1818, "twiceAWeek" , 3),
  thriceAWeek(4, AppStrings.str_student_9_5b9e, "thriceAWeek" , 2);

  final int id;
  final String labelAr;
  final String label;
  final int daysCount;
  const Frequency(this.id, this.labelAr, this.label , this.daysCount);

  static Frequency fromId(int id) {
    return Frequency.values.firstWhere((e) => e.id == id, orElse: () => daily);
  }

  static Frequency fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'onceAWeek':
      case AppStrings.str_student_41_00bb:
      case AppStrings.str_student_7_0fcb:
        return Frequency.onceAWeek;
      case 'twiceAWeek':
      case AppStrings.str_student_8_1818:
        return Frequency.twiceAWeek;
      case 'thriceAWeek':
      case AppStrings.str_student_9_5b9e:
        return Frequency.thriceAWeek;
      default:
        return Frequency.daily;
    }
  }
}
