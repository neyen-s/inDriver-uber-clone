import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/rendering.dart';
import 'package:indriver_uber_clone/core/domain/repositories/socket_repository.dart';
import 'package:indriver_uber_clone/core/errors/error_mapper.dart';
import 'package:indriver_uber_clone/core/network/socket_client.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class SocketRepositoryImpl implements SocketRepository {
  SocketRepositoryImpl({required this.socket});

  SocketClient socket;

  // Reusar controllers por evento para evitar duplicados / handlers huérfanos.
  final Map<String, StreamController<dynamic>> _controllers = {};
  final Map<String, void Function(dynamic)> _handlers = {};

  final Map<String, dynamic> _lastPayloads = {};

  @override
  ResultFuture<void> connect() async {
    try {
      debugPrint('Connecting to socket...');
      await socket.connect();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<void> disconnect() async {
    try {
      // off handlers si tu socket client tiene off(event, handler)
      for (final entry in _handlers.entries) {
        try {
          socket.off(entry.key, entry.value);
        } catch (_) {}
      }
      _handlers.clear();

      for (final entry in _controllers.entries) {
        try {
          entry.value.close();
        } catch (_) {}
      }
      _controllers.clear();

      _lastPayloads.clear();

      socket.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<void> sendMessage(String event, dynamic data) async {
    try {
      socket.emit(event, data);
      return const Right(null);
    } catch (e) {
      debugPrint('Error sending message: $e');
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<Stream<dynamic>> onMessage(String event) async {
    try {
      // si ya existe un controller para ese evento, devolvemos su stream
      if (_controllers.containsKey(event)) {
        debugPrint(
          'SocketRepositoryImpl.onMessage: returning existing controller for $event',
        );
        // replay cached payload (si lo hay) para que el nuevo listener reciba el último estado
        final last = _lastPayloads[event];
        if (last != null) {
          Future.microtask(() {
            final c = _controllers[event];
            if (c != null && !c.isClosed) c.add(last);
          });
        }
        return Right(_controllers[event]!.stream);
      }

      final controller = StreamController<dynamic>.broadcast(
        onListen: () =>
            debugPrint('SocketRepositoryImpl: $event controller listened'),
        onCancel: () =>
            debugPrint('SocketRepositoryImpl: $event controller cancelled'),
      );

      debugPrint('SocketRepositoryImpl.onMessage: registering for $event');

      void handler(dynamic data) {
        debugPrint('<<< SOCKET INCOMING ($event): $data');
        // guardamos el último payload
        _lastPayloads[event] = data;
        if (!controller.isClosed) controller.add(data);
      }

      _controllers[event] = controller;
      _handlers[event] = handler;

      // Registramos en el socket client
      socket.on(event, handler);

      // Si ya teníamos payload previo (por reconexiones), replayarlo a este nuevo controller
      final lastPayload = _lastPayloads[event];
      if (lastPayload != null) {
        Future.microtask(() {
          if (!controller.isClosed) controller.add(lastPayload);
        });
      }

      return Right(controller.stream);
    } catch (e) {
      debugPrint('Error listening to event $event: $e');
      return Left(mapExceptionToFailure(e));
    }
  }

  /// Llamar en teardown si quieres cerrar todo (opcional).
  Future<void> dispose() async {
    for (final entry in _controllers.entries) {
      try {
        await entry.value.close();
      } catch (_) {}
    }
    _controllers.clear();
    _handlers.clear();
  }
}
