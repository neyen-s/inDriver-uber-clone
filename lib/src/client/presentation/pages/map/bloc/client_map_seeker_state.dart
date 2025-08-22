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
    this.selectedLatLng,
    this.address,
    this.selectedField = SelectedField.origin,
    this.driverMarkers = const {},
    this.isSocketConnected = false,
    this.isDrawingRoute = false,
    this.hasCenteredCameraOnce = false,
    this.originAddress,
    this.destinationAddress,
    this.distanceKm,
    this.durationMinutes,
    this.polylines = const {},
    this.origin,
    this.destination,
    this.userMarker,
  });

  final Position? userPosition;
  final LatLng? selectedLatLng;
  final String? address;
  final SelectedField selectedField;
  final Set<Marker> driverMarkers;
  final bool isSocketConnected;
  final bool isDrawingRoute;
  final bool hasCenteredCameraOnce;
  final String? originAddress;
  final String? destinationAddress;
  final double? distanceKm;
  final int? durationMinutes;
  final Map<PolylineId, Polyline> polylines;
  final LatLng? origin;
  final LatLng? destination;
  final Marker? userMarker;

  ClientMapSeekerSuccess copyWith({
    Position? userPosition,
    LatLng? selectedLatLng,
    String? address,
    SelectedField? selectedField,
    Set<Marker>? driverMarkers,
    Set<Polyline>? polylines,
    bool? isSocketConnected,
    bool? isDrawingRoute,
    bool? hasCenteredCameraOnce,
    LatLng? origin,
    LatLng? destination,
    String? originAddress,
    String? destinationAddress,
    double? distanceKm,
    int? durationMinutes,
    Map<PolylineId, Polyline>? mapPolylines,
    Marker? userMarker,
  }) {
    return ClientMapSeekerSuccess(
      userPosition: userPosition ?? this.userPosition,
      selectedLatLng: selectedLatLng ?? this.selectedLatLng,
      address: address ?? this.address,
      selectedField: selectedField ?? this.selectedField,
      driverMarkers: driverMarkers ?? this.driverMarkers,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      isDrawingRoute: isDrawingRoute ?? this.isDrawingRoute,
      hasCenteredCameraOnce:
          hasCenteredCameraOnce ?? this.hasCenteredCameraOnce,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      polylines: mapPolylines ?? this.polylines,
      userMarker: userMarker ?? this.userMarker,
    );
  }

  @override
  List<Object?> get props => [
    userPosition,
    selectedLatLng,
    address,
    selectedField,
    driverMarkers,
    isSocketConnected,
    isDrawingRoute,
    hasCenteredCameraOnce,
    origin,
    destination,
    originAddress,
    destinationAddress,
    distanceKm,
    durationMinutes,
    polylines,
    userMarker,
  ];
}
