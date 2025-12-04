import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shafeea/features/home/domain/entities/plan_detail_entity.dart';
import '../../../daily_tracking/data/datasources/quran_local_data_source.dart';
import 'package:shafeea/features/home/domain/entities/plan_for_the_day_entity.dart';
import 'package:shafeea/features/home/domain/entities/student_info_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/active_status.dart';
import '../../../settings/domain/entities/export_config.dart';
import '../../../settings/domain/entities/import_config.dart';
import '../../../settings/domain/entities/import_export.dart';
import '../../../settings/domain/entities/import_summary.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_local_data_source.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/student_model.dart';
import '../models/tracking_detail_model.dart';
import '../models/tracking_model.dart';
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

  
  // --- NEW FOLLOW-UP REPORTS OPERATIONS ---

  @override
  Future<Either<Failure, String>> exportFollowUpReports({
    required ExportConfig config,
  }) async {
    try {
      // 1. Fetch Data using Core DataSource
      // ملاحظة: نفترض أنك أضفت getAllFollowUpTrackings للـ CoreDataSource
      final reports = await _localDataSource.getAllFollowUpTrackings();

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String();
      final fileExtension = config.fileFormat;
      final file = File('${directory.path}/followup_export_$timestamp.$fileExtension');

      String content = '';
      if (config.fileFormat == DataExportFormat.csv) {
        content = _formatTrackingAsCsv(reports);
      } else {
        content = _formatTrackingAsJson(reports);
      }

      await file.writeAsString(content);
      return Right(file.path);

    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ImportSummary>> importFollowUpReports({
    required ImportConfig config,
  }) async {
    try {
      final file = File(config.filePath);
      final fileContent = await file.readAsString();

      if (config.filePath.endsWith('.csv')) {
        return _importTrackingCsv(fileContent, config.conflictResolution);
      } else if (config.filePath.endsWith('.json')) {
        return _importTrackingJson(fileContent, config.conflictResolution);
      } else {
        return Left(
          CacheFailure(message: 'Unsupported file format for import.'),
        );
      }
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to read import file: $e'));
    }
  }

  // --- PRIVATE HELPER METHODS FOR FOLLOW-UP LOGIC ---

  String _formatTrackingAsCsv(Map<String, List<TrackingModel>> reports) {
    final List<List<dynamic>> rows = [];
    rows.add([
      'studentId', 'trackingId', 'date', 'note', 'attendance', 'behaviorNote',
      'createdAt', 'updatedAt', 'detailType', 'actualAmount', 'gap',
      'performanceScore', 'comment', 'status', 'from_unitId', 'from_fromSurah',
      'from_fromPage', 'from_fromAyah', 'from_toSurah', 'from_toPage',
      'from_toAyah', 'to_unitId', 'to_fromSurah', 'to_fromPage', 'to_fromAyah',
      'to_toSurah', 'to_toPage', 'to_toAyah', 'mistakesJson',
    ]);

    reports.forEach((studentId, trackings) {
      for (final tracking in trackings) {
        if (tracking.details.isEmpty) {
          rows.add([
            studentId, tracking.id, tracking.date, tracking.note,
            tracking.attendanceTypeId, tracking.behaviorNote,
            tracking.createdAt, tracking.updatedAt,
            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
          ]);
        } else {
          for (final detail in tracking.details) {
            final mistakesJson = jsonEncode(detail.mistakes.map((m) => m.toJson()).toList());
            rows.add([
              studentId, tracking.id, tracking.date, tracking.note,
              tracking.attendanceTypeId, tracking.behaviorNote,
              tracking.createdAt, tracking.updatedAt,
              detail.trackingTypeId, detail.actualAmount, detail.gap,
              detail.score, detail.comment, detail.status,
              detail.fromTrackingUnitId.unitId, detail.fromTrackingUnitId.fromSurah,
              detail.fromTrackingUnitId.fromPage, detail.fromTrackingUnitId.fromAyah,
              detail.fromTrackingUnitId.toSurah, detail.fromTrackingUnitId.toPage,
              detail.fromTrackingUnitId.toAyah, detail.toTrackingUnitId.unitId,
              detail.toTrackingUnitId.fromSurah, detail.toTrackingUnitId.fromPage,
              detail.toTrackingUnitId.fromAyah, detail.toTrackingUnitId.toSurah,
              detail.toTrackingUnitId.toPage, detail.toTrackingUnitId.toAyah,
              mistakesJson,
            ]);
          }
        }
      }
    });
    return const ListToCsvConverter().convert(rows);
  }

  String _formatTrackingAsJson(Map<String, List<TrackingModel>> reports) {
    final serializableReports = reports.map((key, value) {
      return MapEntry(key, value.map((tracking) => tracking.toJson()).toList());
    });
    return jsonEncode(serializableReports);
  }

  Future<Either<Failure, ImportSummary>> _importTrackingCsv(
    String csvData,
    ConflictResolution conflictResolution,
  ) async {
    final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
    if (rows.length < 2) {
      return Left(CacheFailure(message: 'CSV file must have a header and at least one data row.'));
    }

    final header = rows.first.map((e) => e.toString()).toList();
    final dataRows = rows.skip(1);
    final trackingsByStudent = <String, Map<String, List<Map<String, dynamic>>>>{};
    final errorMessages = <String>[];
    int successfulRows = 0;

    for (final row in dataRows) {
      try {
        final rowData = Map<String, dynamic>.fromIterables(header, row);
        final studentId = rowData['studentId'] as String;
        final trackingId = rowData['trackingId'] as String;

        trackingsByStudent.putIfAbsent(studentId, () => {});
        trackingsByStudent[studentId]!.putIfAbsent(trackingId, () => []);
        trackingsByStudent[studentId]![trackingId]!.add(rowData);
        successfulRows++;
      } catch (e) {
        errorMessages.add('Error parsing row: ${row.join(',')}. Error: $e');
      }
    }

    final result = <String, List<TrackingModel>>{};
    trackingsByStudent.forEach((studentId, trackingsData) {
      result[studentId] = trackingsData.entries.map((entry) {
        final details = entry.value.map((rowData) => TrackingDetailModel.fromCsvRow(rowData)).toList();
        return TrackingModel.fromCsvRow(entry.value.first, details);
      }).toList();
    });

    // ملاحظة: نفترض أنك أضفت importFollowUpTrackings للـ CoreDataSource
    await _localDataSource.importFollowUpTrackings(
      trackings: result,
      conflictResolution: conflictResolution,
    );

    return Right(ImportSummary(
      totalRows: dataRows.length,
      successfulRows: successfulRows,
      failedRows: errorMessages.length,
      errorMessages: errorMessages,
    ));
  }

  Future<Either<Failure, ImportSummary>> _importTrackingJson(
    String jsonData,
    ConflictResolution conflictResolution,
  ) async {
    final Map<String, dynamic> decodedData = jsonDecode(jsonData);
    final trackingsByStudent = <String, List<TrackingModel>>{};
    int totalRows = 0;

    decodedData.forEach((studentId, trackingsData) {
      final trackings = (trackingsData as List)
          .map((data) => TrackingModel.fromJson(data as Map<String, dynamic>))
          .toList();
      trackingsByStudent[studentId] = trackings;
      totalRows += trackings.length;
    });

    await _localDataSource.importFollowUpTrackings(
      trackings: trackingsByStudent,
      conflictResolution: conflictResolution,
    );

    return Right(ImportSummary(
      totalRows: totalRows,
      successfulRows: totalRows,
      failedRows: 0,
    ));
  }
}
