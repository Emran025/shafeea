import 'dart:async';
import 'package:flutter/foundation.dart';
import 'websocket_service.dart';

class MushafSyncListener {
  final WebSocketService _wsService;
  StreamSubscription? _subscription;
  
  // Stream to emit error marking events to the UI/BLoC
  final _errorMarkController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onErrorMarked => _errorMarkController.stream;

  MushafSyncListener(this._wsService);

  void listen() {
    _subscription = _wsService.messages.listen((data) {
      // Check if the incoming event is a mark_word_error event
      if (data['event'] == 'mark_word_error') {
        final payload = data['data'];
        if (payload != null) {
          // Pass the exact word location to the student's Quran BLoC
          _errorMarkController.add({
            'surah': payload['surah'],
            'ayah': payload['ayah'],
            'word_index': payload['word_index'],
          });
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _errorMarkController.close();
  }
}
