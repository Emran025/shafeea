// lib/features/students/domain/usecases/upsert_student.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

@lazySingleton
class UpsertStudent  {
  final StudentRepository repository;

  UpsertStudent(this.repository);

 
  Future<Either<Failure, StudentDetailEntity>> call(
    StudentDetailEntity student,
  ) async {
    return await repository.upsertStudent(student);
  }
}
