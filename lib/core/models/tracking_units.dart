import 'package:shafeea_student/core/l10n/app_strings.dart';
enum TrackingUnitTyps {
  juz(1, AppStrings.str_student_45_7fc3, "juz"),
  hizb(2, AppStrings.str_student_46_1748, "hizb"),
  halfHizb(3, AppStrings.str_student_47_d6ea, "halfHizb"),
  quarterHizb(4, AppStrings.str_student_48_8b15, "quarterHizb"),
  page(5, AppStrings.str_student_49_b23e, "page");

  final int id;
  final String labelAr;
  final String label;
  const TrackingUnitTyps(this.id, this.labelAr, this.label);

  static TrackingUnitTyps fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'juz':
      case AppStrings.str_student_45_7fc3:
        return TrackingUnitTyps.juz;
      case 'hizb':
      case AppStrings.str_student_46_1748:
        return TrackingUnitTyps.hizb;
      case 'halfHizb':
      case AppStrings.str_student_rem_0_6971:
      case AppStrings.str_student_rem_1_8e9f:
        return TrackingUnitTyps.halfHizb;
      case 'quarterHizb':
      case AppStrings.str_student_rem_2_d2f8:
      case AppStrings.str_student_rem_3_982e:
        return TrackingUnitTyps.quarterHizb;
      default:
        return TrackingUnitTyps.page;
    }
  }

  static TrackingUnitTyps fromId(int id) {
    return TrackingUnitTyps.values.firstWhere(
      (e) => e.id == id,
      orElse: () => page,
    );
  }
}
