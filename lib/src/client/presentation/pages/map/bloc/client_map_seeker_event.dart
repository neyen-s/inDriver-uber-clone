part of 'client_map_seeker_bloc.dart';

sealed class ClientMapSeekerEvent extends Equatable {
  const ClientMapSeekerEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentPositionRequested extends ClientMapSeekerEvent {}

class LoadCurrentLocationWithMarkerRequested extends ClientMapSeekerEvent {
  const LoadCurrentLocationWithMarkerRequested();
}

final class MapMoved extends ClientMapSeekerEvent {
  const MapMoved(this.target);
  final LatLng target;

  @override
  List<Object> get props => [target];
}

final class MapIdle extends ClientMapSeekerEvent {
  const MapIdle(this.latLng);
  final LatLng latLng;
  @override
  List<Object> get props => [latLng];
}

final class GetAddressFromLatLng extends ClientMapSeekerEvent {
  const GetAddressFromLatLng(this.latLng);
  final LatLng latLng;

  @override
  List<Object> get props => [latLng];
}

final class ConfirmTripDataEntered extends ClientMapSeekerEvent {
  const ConfirmTripDataEntered({
    required this.origin,
    required this.destination,
    required this.originLatLng,
    required this.destinationLatLng,
  });
  final String origin;
  final String destination;
  final LatLng originLatLng;
  final LatLng destinationLatLng;

  @override
  List<Object> get props => [
    origin,
    destination,
    originLatLng,
    destinationLatLng,
  ];
}

final class CancelTripConfirmation extends ClientMapSeekerEvent {
  const CancelTripConfirmation();
}

final class ChangeSelectedFieldRequested extends ClientMapSeekerEvent {
  const ChangeSelectedFieldRequested(this.selectedField);
  final SelectedField selectedField;
}

class DrawRouteRequested extends ClientMapSeekerEvent {
  const DrawRouteRequested({
    required this.origin,
    required this.destination,
    this.originText,
    this.destinationText,
  });
  final LatLng origin;
  final LatLng destination;
  final String? originText;
  final String? destinationText;
}
