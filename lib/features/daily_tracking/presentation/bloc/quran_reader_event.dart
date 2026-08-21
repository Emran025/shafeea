part of 'quran_reader_bloc.dart';

abstract class QuranReaderEvent extends Equatable {
  const QuranReaderEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched to load the initial data for the Quran reader,
/// specifically the list of all surahs for the index.
class SurahsListRequested extends QuranReaderEvent {}

/// Event dispatched when the user navigates to a new page.
class PageDataRequested extends QuranReaderEvent {
  final int pageNumber;

  const PageDataRequested(this.pageNumber);

  @override
  List<Object> get props => [pageNumber];
}
/// Event dispatched when the user navigates to a new page.
class MistakesAyahsRequested extends QuranReaderEvent {
  final List<int> mistakes;

  const MistakesAyahsRequested(this.mistakes);

  @override
  List<Object> get props => [mistakes];
}

/// Event dispatched when a real-time error mark is received from the teacher via WebSocket.
class RealTimeErrorMarked extends QuranReaderEvent {
  final int surah;
  final int ayah;
  final int wordIndex;

  const RealTimeErrorMarked({
    required this.surah,
    required this.ayah,
    required this.wordIndex,
  });

  @override
  List<Object> get props => [surah, ayah, wordIndex];
}
