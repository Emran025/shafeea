import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shafeea/features/home/domain/entities/plan_detail_entity.dart';
import '../../../daily_tracking/data/datasources/quran_local_data_source.dart';
import 'package:shafeea/features/home/domain/entities/plan_for_the_day_entity.dart';
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
  final QuranLocalDataSource _quranLocalDataSource;

  // NetworkInfo is not needed here anymore as SyncService handles it.

  StudentRepositoryImpl({
    required StudentLocalDataSource localDataSource,
    required StudentRemoteDataSource remoteDataSource,
    required QuranLocalDataSource quranLocalDataSource,
    required StudentSyncService syncService,
  }) : _localDataSource = localDataSource,
       _quranLocalDataSource = quranLocalDataSource,
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

  @override
  Future<Either<Failure, PlanForTheDayEntity>> getPlanForTheDay() async {
    try {
      final followUpPlan = await _localDataSource.getFollowUpPlan();
      final trackings = await _localDataSource.getFollowUpTrackings();

      if (followUpPlan.details.isEmpty) {
        return Left(CacheFailure(message: 'You have no plan details.'));
      }

      if (trackings.isEmpty) {
        return Right(_getFirstPlan(followUpPlan.details.first.toEntity()));
      }
      for (final lastTracking in trackings) {
        log(
          "----------------------------${lastTracking.createdAt}------------------------------",
        );
      }

      final lastTracking = trackings.last;
      final lastTrackingDate = DateTime.parse(lastTracking.createdAt);
      final frequency = followUpPlan.frequency;
      final daysCount = frequency.daysCount;
      final nextTrackingDate = lastTrackingDate.add(Duration(days: daysCount));
      final now = DateTime.now();

      if (now.isBefore(nextTrackingDate)) {
        return Left(
          CacheFailure(
            message:
                'You have already completed your plan for today. Please come back tomorrow.',
          ),
        );
      }

      final planDetails = followUpPlan.details;

      if (lastTracking.details.isEmpty) {
        return Right(_getFirstPlan(planDetails.first.toEntity()));
      }

      final lastTrackingDetail = lastTracking.details.first;
      final toTrackingUnitId = lastTrackingDetail.toTrackingUnitId;

      // if (toTrackingUnitId.fromAyah == null) {
      //   return Right(_getFirstPlan(planDetails.first.toEntity()));
      // }

      final fromAyah = await _quranLocalDataSource.getAyahById(
        toTrackingUnitId.fromAyah + 1,
      );

      final lastCompletedPlanDetailIndex = trackings.length - 1;

      if (lastCompletedPlanDetailIndex + 1 >= planDetails.length) {
        return Left(
          CacheFailure(message: 'You have completed all your plan details.'),
        );
      }

      final nextPlanDetail = planDetails[lastCompletedPlanDetailIndex + 1]
          .toEntity();
      final getSurahsList = await _quranLocalDataSource.getSurahsList();
      final toAyah = (await _quranLocalDataSource.getAyahById(
        toTrackingUnitId.fromAyah + nextPlanDetail.amount,
      )).toEntity();

      return Right(
        PlanForTheDayEntity(
          planDetail: nextPlanDetail,
          fromSurah: getSurahsList[fromAyah.surahNumber].name,
          fromPage: fromAyah.page,
          fromAyah: fromAyah.number,
          toSurah: getSurahsList[toAyah.surahNumber].name,
          toPage: toAyah.page,
          toAyah: toAyah.number,
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  PlanForTheDayEntity _getFirstPlan(PlanDetailEntity planDetail) {
    return PlanForTheDayEntity(
      planDetail: planDetail,
      fromSurah: 'Al-Fatihah',
      fromPage: 1,
      fromAyah: 1,
      toSurah: 'Al-Fatihah',
      toPage: 1,
      toAyah: planDetail.amount,
    );
  }
}
