part of 'client_map_seeker_bloc.dart';

sealed class ClientMapSeekerState extends Equatable {
  const ClientMapSeekerState();

  @override
  List<Object> get props => [];
}

class ClientMapSeekerInitial extends ClientMapSeekerState {}

class ClientMapSeekerLoading extends ClientMapSeekerState {}

class FindPositionSuccess extends ClientMapSeekerState {
  const FindPositionSuccess(this.position);
  final Position position;

  @override
  List<Object> get props => [position];
}

class ClientMapSeekerError extends ClientMapSeekerState {
  const ClientMapSeekerError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class PositionWithMarkerSuccess extends ClientMapSeekerState {
  const PositionWithMarkerSuccess({
    required this.position,
    required this.marker,
  });

  final Position position;
  final Marker marker;

  @override
  List<Object> get props => [position, marker];
}
