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

  final LatLng position;
  final Marker marker;

  @override
  List<Object> get props => [position, marker];
}

final class AddressUpdatedSuccess extends ClientMapSeekerState {
  const AddressUpdatedSuccess(this.address, this.field);

  final String address;
  final SelectedField field;

  @override
  List<Object> get props => [address, field];
}

final class SelectedFieldChanged extends ClientMapSeekerState {
  const SelectedFieldChanged(this.selectedField);
  final SelectedField selectedField;

  @override
  List<Object> get props => [selectedField];
}

final class FetchingTextAdress extends ClientMapSeekerState {
  const FetchingTextAdress(this.field);

  final SelectedField field;

  @override
  List<Object> get props => [field];
}

final class RouteDrawingInProgress extends ClientMapSeekerState {
  const RouteDrawingInProgress();
}

final class TripReadyToDisplay extends ClientMapSeekerState {
  const TripReadyToDisplay({
    required this.origin,
    required this.destination,
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMinutes,
  });

  final String origin;
  final String destination;
  final List<PointLatLng> polylinePoints;
  final double distanceKm;
  final int durationMinutes;

  @override
  List<Object> get props => [
    origin,
    destination,
    polylinePoints,
    distanceKm,
    durationMinutes,
  ];
}
