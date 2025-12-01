import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
// import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/active_status.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/student_info_entity.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/generate_follow_up_report_use_case.dart';
import '../../domain/usecases/get_student_by_id.dart';
import '../../domain/usecases/set_student_status_params.dart';
import '../../domain/usecases/upsert_student_usecase.dart';
import '../view_models/follow_up_report_bundle_entity.dart';

part 'student_event.dart';
part 'student_state.dart';

// @injectable
class StudentBloc extends Bloc<StudentEvent, StudentState> {

  final GetStudentById _getStudentByIdUC;
  final UpsertStudent _upsertStudentUC;
  final DeleteStudentUseCase _deleteStudentUC;
  final SetStudentStatusUseCase _setStudentStatusUC;
  final GenerateFollowUpReportUseCase _generateFollowUpReportUC;

  StudentBloc({
    required GetStudentById getStudentById,
    required UpsertStudent upsertStudent,
    required DeleteStudentUseCase deleteStudent,
    required SetStudentStatusUseCase setStudentStatus,
    required GenerateFollowUpReportUseCase generateFollowUpReportUC,
  }) : 
       _upsertStudentUC = upsertStudent,
       _deleteStudentUC = deleteStudent,
       _getStudentByIdUC = getStudentById,
       _setStudentStatusUC = setStudentStatus,
       _generateFollowUpReportUC = generateFollowUpReportUC,

       super(const StudentState()) {

    on<StudentUpserted>(_onUpsert, transformer: droppable());
    on<StudentDeleted>(_onDelete, transformer: droppable());
    on<StudentDetailsFetched>(_onFetchDetails, transformer: restartable());
    on<StudentStatusChanged>(_onStatusChange, transformer: droppable());
    on<FollowUpReportFetched>(_onFetchReport, transformer: droppable());

  }


  /// Handles the fetching of a single student's detailed profile.
  Future<void> _onFetchDetails(
    StudentDetailsFetched event,
    Emitter<StudentState> emit,
  ) async {
    // 1. Emit a loading state specifically for the details view.
    //    This does not affect the main list's status.
    emit(
      state.copyWith(
        detailsStatus: StudentInfoStatus.loading,
        clearDetailsFailure: true,
      ),
    );

    // 2. Call the use case to fetch the data.
    final result = await _getStudentByIdUC();

    // 3. Fold the result and emit either a success or failure state.
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailsStatus: StudentInfoStatus.failure,
          detailsFailure: failure,
        ),
      ),
      (studentDetails) => emit(
        state.copyWith(
          detailsStatus: StudentInfoStatus.success,
          selectedStudent: studentDetails,
        ),
      ),
    );
  }


  /// Handles the creation or update of a student.
  Future<void> _onUpsert(
    StudentUpserted event,
    Emitter<StudentState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: StudentSubmissionStatus.submitting,
        clearSubmissionFailure: true,
      ),
    );

    final result = await _upsertStudentUC(event.student);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) {
        // On success, the list will update automatically via the stream.
        // We just need to signal that the submission process is complete.
        emit(state.copyWith(submissionStatus: StudentSubmissionStatus.success));
      },
    );
  }

  /// Handles the deletion of a student.
  Future<void> _onDelete(
    StudentDeleted event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: StudentSubmissionStatus.submitting));

    final result = await _deleteStudentUC();

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(submissionStatus: StudentSubmissionStatus.success),
      ),
    );
  }

  /// Handles changing a student's status (e.g., active, suspended).
  Future<void> _onStatusChange(
    StudentStatusChanged event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: StudentSubmissionStatus.submitting));

    final result = await _setStudentStatusUC(
      SetStudentStatusParams(
   
        newStatus: event.newStatus,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(submissionStatus: StudentSubmissionStatus.success),
      ),
    );
  }

  Future<void> _onFetchReport(
    FollowUpReportFetched event,
    Emitter<StudentState> emit,
  ) async {
    emit(
      state.copyWith(
        followUpReportStatus: FollowUpReportStatus.loading,
        clearFollowUpReportFailure: true,
      ),
    );

    final result = await _generateFollowUpReportUC();

    result.fold(
      (failure) => emit(
        state.copyWith(
          followUpReportStatus: FollowUpReportStatus.failure,
          detailsFailure: failure,
        ),
      ),
      (followUpReport) {
        print(followUpReport);
        emit(
          state.copyWith(
            followUpReportStatus: FollowUpReportStatus.success,
            followUpReport: followUpReport,
          ),
        );
      },
    );
  }

}
