part of 'socket_bloc.dart';

sealed class SocketState extends Equatable {
  const SocketState();
  @override
  List<Object?> get props => [];
}

class SocketLoading extends SocketState {}

class SocketInitial extends SocketState {}

class SocketConnected extends SocketState {}

class SocketDisconnected extends SocketState {}

class SocketError extends SocketState {
  const SocketError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class SocketDriverPositionsUpdated extends SocketState {
  const SocketDriverPositionsUpdated(this.drivers);
  final Map<String, LatLng> drivers; // key = idSocket

  @override
  List<Object?> get props => [drivers];
}

class SocketClientRequestCreated extends SocketState {
  const SocketClientRequestCreated(this.idClientRequest);
  final String idClientRequest;

  @override
  List<Object?> get props => [idClientRequest];
}

class SocketDriverOfferArrived extends SocketState {
  const SocketDriverOfferArrived({
    required this.idClientRequest,
    required this.payload,
  });

  final String idClientRequest;
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [idClientRequest, payload];
}

class SocketRequestRemovedState extends SocketState {
  const SocketRequestRemovedState(this.idClientRequest);
  final String idClientRequest;

  @override
  List<Object?> get props => [idClientRequest];
}

class SocketDriverAssignedState extends SocketState {
  const SocketDriverAssignedState({
    required this.idClientRequest,
    required this.idDriver,
  });
  final String idClientRequest;
  final String idDriver;

  @override
  List<Object?> get props => [idClientRequest, idDriver];
}
