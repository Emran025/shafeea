import 'package:shafeea_student/core/l10n/app_strings.dart';
/// Enhanced enum representing the different types of recitation mistakes.
///
/// Each member has an `id` for database storage and a `labelAr` for display in the UI.
enum MistakeType {
  // id, Arabic Label
  none(0, AppStrings.str_student_36_c6e1),
  memory(1, AppStrings.str_student_37_506b),
  grammar(2, AppStrings.str_student_38_4438),
  pronunciation(3, AppStrings.str_student_39_8478),
  timing(4, AppStrings.str_student_40_76e7);
  // You can easily add more types here in the future.
  
  final int id;
  final String labelAr;
  const MistakeType(this.id, this.labelAr);

  /// A utility method to find a [MistakeType] by its integer ID.
  ///
  /// This is useful when retrieving data from the database.
  /// Defaults to [MistakeType.none] if the id is not found.
  static MistakeType fromId(int id) {
    return MistakeType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => none,
    );
  }
}