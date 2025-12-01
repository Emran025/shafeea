import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shafeea/features/home/domain/entities/student_info_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/active_status.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_local_data_source.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/student_model.dart';
import '../services/student_sync_service.dart';

@LazySingleton(as: StudentRepository)
final class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalDataSource _localDataSource;
  final StudentSyncService _syncService;

  // NetworkInfo is not needed here anymore as SyncService handles it.

  StudentRepositoryImpl({
    required StudentLocalDataSource localDataSource,
    required StudentRemoteDataSource remoteDataSource,

    required StudentSyncService syncService,
  }) : _localDataSource = localDataSource,
       _syncService = syncService;

  @override
  Future<Either<Failure, StudentDetailEntity>> upsertStudent(
    StudentDetailEntity student,
  ) async {
    try {
      // 1. Convert the domain entity to a data model.
      final model = StudentModel.fromEntity(student);

      // 2. Immediately save to the local DB for instant UI feedback.
      await _localDataSource.upsertStudent(model);

      // 3. Queue the operation for the next sync cycle.
      // await _localDataSource.queueSyncOperation(
      //   uuid: student.id,
      //   operation: 'upsert',
      //   payload: model.toMap(),
      // );

      // 5. Return the updated entity.
      return Right(student);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteStudent() async {
    try {
      // 1. Perform a soft delete locally for instant UI update.
      await _localDataSource.deleteStudent();

      // 2. Queue the delete operation for the sync engine.
      // await _localDataSource.queueSyncOperation(
      //   uuid: studentId,
      //   operation: 'delete',
      // );

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, StudentInfoEntity>> getStudentById() async {
    // This method would typically fetch from the local data source first,
    // then potentially trigger a targeted remote fetch if needed.
    try {
      await _syncService.performTrackingsSync();
      final model = await _localDataSource.getStudentInfoById();
      return Right(model.toStudentInfoEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  /// Returns [Right(unit)] on success, or a [Left(Failure)] on error.
  @override
  Future<Either<Failure, Unit>> setStudentStatus({
    required ActiveStatus newStatus,
  }) async {
    return const Right(unit);
  }
}
