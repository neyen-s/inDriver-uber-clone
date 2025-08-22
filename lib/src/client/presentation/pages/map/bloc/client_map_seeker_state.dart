part of 'client_map_seeker_bloc.dart';

sealed class ClientMapSeekerState extends Equatable {
  const ClientMapSeekerState();

  @override
  List<Object?> get props => [];
}

class ClientMapSeekerInitial extends ClientMapSeekerState {}

class ClientMapSeekerLoading extends ClientMapSeekerState {}

class ClientMapSeekerError extends ClientMapSeekerState {
  const ClientMapSeekerError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ClientMapSeekerSuccess extends ClientMapSeekerState {
  const ClientMapSeekerSuccess({
    this.userPosition,
    this.selectedField = SelectedField.origin,
    this.driverMarkers = const {},
    this.isSocketConnected = false,
    this.hasCenteredCameraOnce = false,
    this.originAddress,
    this.destinationAddress,
    this.distanceKm,
    this.durationMinutes,
    this.polylines = const {},
    this.origin,
    this.destination,
  });

  final Position? userPosition;
  final SelectedField selectedField;
  final Set<Marker> driverMarkers;
  final bool isSocketConnected;
  final bool hasCenteredCameraOnce;
  final String? originAddress;
  final String? destinationAddress;
  final double? distanceKm;
  final int? durationMinutes;
  final Map<PolylineId, Polyline> polylines;
  final LatLng? origin;
  final LatLng? destination;

  ClientMapSeekerSuccess copyWith({
    Position? userPosition,
    SelectedField? selectedField,
    Set<Marker>? driverMarkers,
    Set<Polyline>? polylines,
    bool? isSocketConnected,
    bool? hasCenteredCameraOnce,
    LatLng? origin,
    LatLng? destination,
    String? originAddress,
    String? destinationAddress,
    double? distanceKm,
    int? durationMinutes,
    Map<PolylineId, Polyline>? mapPolylines,
  }) {
    return ClientMapSeekerSuccess(
      userPosition: userPosition ?? this.userPosition,
      selectedField: selectedField ?? this.selectedField,
      driverMarkers: driverMarkers ?? this.driverMarkers,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      hasCenteredCameraOnce:
          hasCenteredCameraOnce ?? this.hasCenteredCameraOnce,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      polylines: mapPolylines ?? this.polylines,
    );
  }

  @override
  List<Object?> get props => [
    userPosition,
    selectedField,
    driverMarkers,
    isSocketConnected,
    hasCenteredCameraOnce,
    origin,
    destination,
    originAddress,
    destinationAddress,
    distanceKm,
    durationMinutes,
    polylines,
  ];
}
