import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketClient {
  Socket? _socket;
  Completer<void>? _connectCompleter;

  Socket get socket {
    if (_socket == null) {
      throw Exception('Socket not connected. Call connect() first.');
    }
    return _socket!;
  }

  Future<void> connect({
    Map<String, dynamic>? extraHeaders,
    Duration timeout = const Duration(seconds: 10),
  }) {
    if (_connectCompleter != null) return _connectCompleter!.future;
    if (_socket != null) {
      // ya conectado o intentando -> devuelve el future existente si existe
      if (_connectCompleter != null) {
        return _connectCompleter!.future;
      }
    }

    _connectCompleter = Completer<void>();

    _socket = io(
      'http://$apiProject',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ Socket Connected to https://$apiProject');
      if (!(_connectCompleter?.isCompleted ?? false)) {
        _connectCompleter!.complete();
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Socket Disconnected');
    });

    _socket!.onError((err) {
      debugPrint('⚠️ socket Error: $err');
      if (!(_connectCompleter?.isCompleted ?? false)) {
        _connectCompleter!.completeError((err ?? 'socket error') as Object);
      }
    });

    // some versions emit 'connect_error'
    try {
      _socket!.on('connect_error', (err) {
        debugPrint('⚠️ socket connect_error: $err');
        if (!(_connectCompleter?.isCompleted ?? false)) {
          _connectCompleter!.completeError((err ?? 'connect_error') as Object);
        }
      });
    } catch (_) {}

    _socket!.connect();

    // Return the completer's future with timeout to avoid hanging forever
    return _connectCompleter!.future.timeout(
      timeout,
      onTimeout: () {
        if (!(_connectCompleter?.isCompleted ?? false)) {
          _connectCompleter!.completeError('connect timeout');
        }
        throw TimeoutException('Socket connect timeout');
      },
    );
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _connectCompleter = null; // reset completer
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, void Function(dynamic) callback) {
    _socket?.on(event, callback);
  }
}
