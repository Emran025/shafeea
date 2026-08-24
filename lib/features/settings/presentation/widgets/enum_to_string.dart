import 'package:shafeea/core/l10n/app_strings.dart' as L10nStrings;
import '../../domain/entities/import_export.dart';

String toDisplayString(dynamic anEnum) {
  switch (anEnum) {
    case EntityType.followUpReport:
      return L10nStrings.AppStrings.followUpData;
    case DataExportFormat.csv:
      return 'CSV';
    case DataExportFormat.json:
      return 'JSON';
    case ConflictResolution.skip:
      return L10nStrings.AppStrings.ignoreOption;
    case ConflictResolution.overwrite:
      return L10nStrings.AppStrings.overwriteOption;
    default:
      return anEnum.toString().split('.').last;
  }
}
