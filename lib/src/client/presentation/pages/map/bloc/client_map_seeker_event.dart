part of 'client_map_seeker_bloc.dart';

sealed class ClientMapSeekerEvent extends Equatable {
  const ClientMapSeekerEvent();

  @override
  List<Object?> get props => [];
}

class GetCurrentPositionRequested extends ClientMapSeekerEvent {}

final class GetAddressFromLatLng extends ClientMapSeekerEvent {
  const GetAddressFromLatLng(
    this.latLng, {
    this.selectedField = SelectedField.origin,
  });
  final LatLng latLng;
  final SelectedField selectedField;

  @override
  List<Object> get props => [latLng, selectedField];
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

  @override
  List<Object> get props => [
    origin,
    destination,
    originText ?? '',
    destinationText ?? '',
  ];
}

class AddDriverPositionMarker extends ClientMapSeekerEvent {
  const AddDriverPositionMarker({
    required this.idSocket,
    required this.lat,
    required this.lng,
  });

  final String idSocket;
  final double lat;
  final double lng;
  @override
  List<Object> get props => [idSocket, lat, lng];
}

class ClientMapCameraCentered extends ClientMapSeekerEvent {}

class RemoveDriverPositionMarker extends ClientMapSeekerEvent {
  const RemoveDriverPositionMarker(this.idSocket);
  final String idSocket;

  @override
  List<Object> get props => [idSocket];
}

class ClearDriverMarkers extends ClientMapSeekerEvent {
  const ClearDriverMarkers();
}

class DriversSnapshotReceived extends ClientMapSeekerEvent {
  const DriversSnapshotReceived(this.drivers);
  final Map<String, LatLng> drivers;

  @override
  List<Object?> get props => [drivers];
}

class ResetCameraRequested extends ClientMapSeekerEvent {}

class GetTimeAndDistanceValuesRequested extends ClientMapSeekerEvent {
  const GetTimeAndDistanceValuesRequested({
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;

  @override
  List<Object> get props => [
    originLat,
    originLng,
    destinationLat,
    destinationLng,
  ];
}

class CreateClientRequest extends ClientMapSeekerEvent {
  const CreateClientRequest({required this.fareOffered});
  final double fareOffered;
  @override
  List<Object?> get props => [fareOffered];
}

final class _SocketStatusChanged extends ClientMapSeekerEvent {
  const _SocketStatusChanged(this.isConnected);
  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}
