import 'package:flutter_test/flutter_test.dart';
import 'package:shafeea/core/services/mushaf_sync_listener.dart';
import 'package:shafeea/core/services/websocket_service.dart';
import 'dart:async';

class MockWebSocketService implements WebSocketService {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  void emitError(Map<String, dynamic> data) {
    _controller.add({
      'event': 'mark_word_error',
      'data': {
        'surah': data['surah'],
        'ayah': data['ayah'],
        'word_index': data['word_index'],
      }
    });
  }
  
  @override
  void dispose() {}
  
  @override
  Future<void> connect() async {}
  
  @override
  void send(Map<String, dynamic> data) {}

  @override
  void disconnect() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('MushafSyncListener Tests', () {
    late MockWebSocketService mockWs;
    late MushafSyncListener listener;

    setUp(() {
      mockWs = MockWebSocketService();
      listener = MushafSyncListener(mockWs);
    });

    test('should emit event when error_marked is received', () async {
      listener.listen();
      final futureEvent = listener.onErrorMarked.first;
      
      mockWs.emitError({
        'surah': 1,
        'ayah': 2,
        'word_index': 3,
      });
      
      final event = await futureEvent;
      
      expect(event['surah'], equals(1));
      expect(event['ayah'], equals(2));
      expect(event['word_index'], equals(3));
    });
  });
}
