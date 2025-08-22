part of 'client_map_seeker_bloc.dart';

sealed class ClientMapSeekerEvent extends Equatable {
  const ClientMapSeekerEvent();

  @override
  List<Object> get props => [];
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

/* final class ConfirmTripDataEntered extends ClientMapSeekerEvent {
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
} */

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

class ConnectSocketIo extends ClientMapSeekerEvent {
  const ConnectSocketIo();
}

class DisconnectSocketIo extends ClientMapSeekerEvent {
  const DisconnectSocketIo();
}

class ListenDriverPositionSocket extends ClientMapSeekerEvent {
  const ListenDriverPositionSocket(this.lat, this.lng);
  final double lat;
  final double lng;
  @override
  List<Object> get props => [lat, lng];
}

class AddDriverPositionMarker extends ClientMapSeekerEvent {
  const AddDriverPositionMarker({
    required this.idSocket,
    required this.id,
    required this.lat,
    required this.lng,
  });

  final String idSocket;
  final int id;
  final double lat;
  final double lng;
  @override
  List<Object> get props => [idSocket, id, lat, lng];
}

class ClientMapCameraCentered extends ClientMapSeekerEvent {}
