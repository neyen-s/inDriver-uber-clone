import 'package:flutter/foundation.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketClient {
  Socket? _socket;

  Socket get socket {
    if (_socket == null) {
      throw Exception('Socket not connected. Call connect() first.');
    }
    return _socket!;
  }

  void connect({Map<String, dynamic>? extraHeaders}) {
    _socket = io(
      'http://$apiProject',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );
    print('http://$apiProject ');
    print('testt testt SOKET----------------');
    _socket!.connect();

    _socket!.onConnect(
      (_) => debugPrint('✅ Socket Connected to ${'https://$apiProject'}'),
    );
    _socket!.onDisconnect((_) => debugPrint('❌ Socket Disconnected'));
    _socket!.onError((err) => debugPrint('⚠️ socket Error: $err'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, void Function(dynamic) callback) {
    _socket?.on(event, callback);
  }
}
