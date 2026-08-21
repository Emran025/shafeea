import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shafeea/features/daily_tracking/presentation/bloc/quran_reader_bloc.dart';
import 'package:shafeea/core/services/mushaf_sync_listener.dart';
import 'package:shafeea/core/utils/data_status.dart';
import 'dart:async';
import 'package:mocktail/mocktail.dart';

import 'package:shafeea/features/daily_tracking/domain/usecases/get_page_data.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_mistakes_ayahs.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_surahs_list.dart';

class MockGetPageData extends Mock implements GetPageData {}
class MockGetMistakesAyahs extends Mock implements GetMistakesAyahs {}
class MockGetSurahsList extends Mock implements GetSurahsList {}

class MockMushafSyncListener extends Mock implements MushafSyncListener {
  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();
  
  @override
  Stream<Map<String, dynamic>> get onErrorMarked => _controller.stream;

  @override
  void listen() {}
  
  void emitError() {
    _controller.add({
      'surah': 1,
      'ayah': 2,
      'word_index': 3,
    });
  }
}

void main() {
  group('QuranReaderBloc RealTimeErrorMarked', () {
    late MockGetPageData mockGetPageData;
    late MockGetMistakesAyahs mockGetMistakesAyahs;
    late MockGetSurahsList mockGetSurahsList;
    late MockMushafSyncListener mockListener;

    setUp(() {
      mockGetPageData = MockGetPageData();
      mockGetMistakesAyahs = MockGetMistakesAyahs();
      mockGetSurahsList = MockGetSurahsList();
      mockListener = MockMushafSyncListener();
    });

    blocTest<QuranReaderBloc, QuranReaderState>(
      'should emit new state when RealTimeErrorMarked is added',
      build: () => QuranReaderBloc(
        getPageData: mockGetPageData,
        getMistakesAyahs: mockGetMistakesAyahs,
        getSurahsList: mockGetSurahsList,
      ),
      act: (bloc) => bloc.add(const RealTimeErrorMarked(surah: 1, ayah: 2, wordIndex: 3)),
      expect: () => [
        isA<QuranReaderState>().having((s) => s.mistakesAyahsStatus, 'mistakesAyahsStatus', DataStatus.success)
      ],
    );

    test('should subscribe to MushafSyncListener and dispatch RealTimeErrorMarked event', () async {
      final bloc = QuranReaderBloc(
        getPageData: mockGetPageData,
        getMistakesAyahs: mockGetMistakesAyahs,
        getSurahsList: mockGetSurahsList,
        mushafSyncListener: mockListener,
      );

      // We expect the state to eventually change to success
      expectLater(
        bloc.stream,
        emits(isA<QuranReaderState>().having((s) => s.mistakesAyahsStatus, 'mistakesAyahsStatus', DataStatus.success)),
      );

      // Simulate receiving an error from the websocket
      mockListener.emitError();
    });
  });
}
