part of 'student_bloc.dart';

enum StudentStatus { initial, loading, success, failure }

enum StudentInfoStatus { initial, loading, success, failure }

enum StudentSubmissionStatus { initial, submitting, success, failure }

enum StudentUpsertStatus { initial, submitting, success, failure }

enum PlanForTheDayStatus { initial, loading, success, failure }

final class StudentState extends Equatable {

  // --- Details State Properties (New) ---
  final StudentInfoStatus detailsStatus;
  final StudentInfoEntity? selectedStudent;
  final Failure? detailsFailure;

  // --- Operation State (New) ---
  final StudentSubmissionStatus submissionStatus;
  final Failure? submissionFailure;
  // --- Operation State (New) ---
  final StudentUpsertStatus upsertStatus;
  final Failure? upsertFailure;

  final PlanForTheDayStatus planForTheDayStatus;
  final PlanForTheDayEntity? planForTheDay;
  final Failure? planForTheDayFailure;

  const StudentState({
    // New
    this.detailsStatus = StudentInfoStatus.initial,
    this.selectedStudent,
    this.detailsFailure,

    // New
    this.submissionStatus = StudentSubmissionStatus.initial,
    this.submissionFailure,
    // New
    this.upsertStatus = StudentUpsertStatus.initial,
    this.upsertFailure,
    this.planForTheDayStatus = PlanForTheDayStatus.initial,
    this.planForTheDay,
    this.planForTheDayFailure,
  });

  StudentState copyWith({
    // New
    StudentInfoStatus? detailsStatus,
    StudentInfoEntity? selectedStudent,
    Failure? detailsFailure,
    // Flags to clear specific errors
    bool clearListFailure = false,
    bool clearDetailsFailure = false,

    // New
    StudentSubmissionStatus? submissionStatus,
    Failure? submissionFailure,
    bool clearSubmissionFailure = false,
    // New
    StudentUpsertStatus? upsertStatus,
    Failure? upsertFailure,
    bool clearUpsertFailure = false,
    PlanForTheDayStatus? planForTheDayStatus,
    PlanForTheDayEntity? planForTheDay,
    Failure? planForTheDayFailure,
    bool clearPlanForTheDayFailure = false,
  }) {
    return StudentState(
      // New
      detailsStatus: detailsStatus ?? this.detailsStatus,
      selectedStudent: selectedStudent ?? this.selectedStudent,
      detailsFailure:
          clearDetailsFailure ? null : detailsFailure ?? this.detailsFailure,

      // New
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submissionFailure: clearSubmissionFailure
          ? null
          : submissionFailure ?? this.submissionFailure,
      // New
      upsertStatus: upsertStatus ?? this.upsertStatus,
      upsertFailure:
          clearUpsertFailure ? null : upsertFailure ?? this.upsertFailure,
      planForTheDayStatus: planForTheDayStatus ?? this.planForTheDayStatus,
      planForTheDay: planForTheDay ?? this.planForTheDay,
      planForTheDayFailure: clearPlanForTheDayFailure
          ? null
          : planForTheDayFailure ?? this.planForTheDayFailure,
    );
  }

  @override
  List<Object?> get props => [
        detailsStatus,
        selectedStudent,
        detailsFailure,
        submissionStatus,
        submissionFailure,
        upsertStatus,
        upsertFailure,
        planForTheDayStatus,
        planForTheDay,
        planForTheDayFailure,
      ];
}

