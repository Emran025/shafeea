// lib/features/students/domain/usecases/delete_student.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shafeea/core/error/failures.dart';

import '../repositories/student_repository.dart';
import 'usecase.dart';

@lazySingleton
class DeleteStudentUseCase  implements UseCase<Unit, NoParams> {
  final StudentRepository repository;

  DeleteStudentUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.deleteStudent();
  }
}
