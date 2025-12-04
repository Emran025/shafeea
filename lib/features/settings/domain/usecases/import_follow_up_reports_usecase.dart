import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/repositories/student_repository.dart';
import '../entities/import_config.dart';
import '../entities/import_summary.dart';

@injectable
class ImportFollowUpReportsUseCase
    extends UseCase<ImportSummary, ImportConfig> {
  final StudentRepository _studentRepository;

  ImportFollowUpReportsUseCase(this._studentRepository);

  @override
  Future<Either<Failure, ImportSummary>> call(ImportConfig params) async {
    return await _studentRepository.importFollowUpReports(config: params);
  }
}