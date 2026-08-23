import 'package:shafeea_student/core/l10n/app_strings.dart';
import '../../domain/entities/import_export.dart';

String toDisplayString(dynamic anEnum) {
  switch (anEnum) {
    case EntityType.followUpReport:
      return AppStrings.str_student_rem_259_301e;
    case DataExportFormat.csv:
      return 'CSV';
    case DataExportFormat.json:
      return 'JSON';
    case ConflictResolution.skip:
      return AppStrings.str_student_rem_260_50af;
    case ConflictResolution.overwrite:
      return AppStrings.str_student_rem_261_e6f0;
    default:
      return anEnum.toString().split('.').last;
  }
}
