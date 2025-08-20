import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/domain/repositories/socket_repository.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/network/socket_client.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class SocketRepositoryImpl implements SocketRepository {
  SocketRepositoryImpl({required this.socket});

  SocketClient socket;

  @override
  ResultFuture<void> connect() async {
    try {
      print('Connecting to socket...');
      socket.connect();
      return const Right(null);
    } catch (e) {
      return Left(SocketFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> disconnect() async {
    try {
      socket.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(SocketFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> sendMessage(String event, dynamic data) async {
    try {
      socket.emit(event, data);
      return const Right(null);
    } catch (e) {
      print('Error sending message: $e');
      return Left(SocketFailure(message: e.toString()));
    }
  }

  @override
  Stream<dynamic> onMessage(String event) {
    // TODO: implement onMessage
    throw UnimplementedError();
  }
}
