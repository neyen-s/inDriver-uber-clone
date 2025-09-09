import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/rendering.dart';
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
      debugPrint('Connecting to socket...');
      await socket.connect();
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
      debugPrint('Error sending message: $e');
      return Left(SocketFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Stream<dynamic>> onMessage(String event) async {
    try {
      final controller = StreamController<dynamic>();

      socket.on(event, controller.add);

      return Right(controller.stream);
    } catch (e) {
      debugPrint('Error listening to event $event: $e');
      return Left(SocketFailure(message: e.toString()));
    }
  }
}
