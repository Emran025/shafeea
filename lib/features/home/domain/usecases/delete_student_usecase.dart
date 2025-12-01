// lib/features/students/domain/usecases/delete_student.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shafeea/core/error/failures.dart';

import '../repositories/student_repository.dart';

@lazySingleton
class DeleteStudentUseCase {
  final StudentRepository repository;

  DeleteStudentUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.deleteStudent();
  }
}
