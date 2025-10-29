part of 'socket_bloc.dart';

sealed class SocketEvent extends Equatable {
  const SocketEvent();
  @override
  List<Object?> get props => [];
}

class ConnectSocket extends SocketEvent {}

class DisconnectSocket extends SocketEvent {}

class SocketDriverPositionReceived extends SocketEvent {
  const SocketDriverPositionReceived({
    required this.idSocket,
    required this.lat,
    required this.lng,
  });
  final String idSocket;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [idSocket, lat, lng];
}

class SendDriverPositionRequested extends SocketEvent {
  const SendDriverPositionRequested({
    required this.idDriver,
    required this.lat,
    required this.lng,
  });

  final int idDriver;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [idDriver, lat, lng];
}

final class SocketDriverDisconnectedReceived extends SocketEvent {
  const SocketDriverDisconnectedReceived({required this.idSocket});
  final String idSocket;

  @override
  List<Object?> get props => [idSocket];
}

// nuevo evento para snapshot inicial atómico
class SocketDriversSnapshotReceived extends SocketEvent {
  const SocketDriversSnapshotReceived(this.drivers);
  final Map<String, LatLng> drivers;

  @override
  List<Object?> get props => [drivers];
}

class SocketDriverRemovalTimeout extends SocketEvent {
  const SocketDriverRemovalTimeout(this.idSocket);
  final String idSocket;

  @override
  List<Object?> get props => [idSocket];
}

final class SocketClientRequestReceived extends SocketEvent {
  const SocketClientRequestReceived({required this.idClientRequest});
  final String idClientRequest;

  @override
  List<Object?> get props => [idClientRequest];
}

// socket_event.dart
final class SendNewClientRequestRequested extends SocketEvent {
  const SendNewClientRequestRequested({required this.idClientRequest});
  final String idClientRequest;

  @override
  List<Object?> get props => [idClientRequest];
}
