import 'package:shafeea_student/core/l10n/app_strings.dart';
enum Gender {
  male(1, AppStrings.str_student_33_82db, 'Male'),
  female(2, AppStrings.str_student_34_46ea, 'Female'),
  both(3, AppStrings.str_student_35_b479, 'Both');

  final int id;
  final String labelAr;
  final String label;
  const Gender(this.id, this.labelAr, this.label);

  /// A utility method to find a [MistakeType] by its integer ID.
  ///
  /// This is useful when retrieving data from the database.
  /// Defaults to [Gender.none] if the id is not found.
  static Gender fromId(int id) {
    return Gender.values.firstWhere((e) => e.id == id, orElse: () => male);
  }

  static Gender fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'female':
      case AppStrings.str_student_34_46ea:
        return Gender.female;
      default:
        return Gender.male;
    }
  }
}
