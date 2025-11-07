part of 'client_map_seeker_bloc.dart';

sealed class ClientMapSeekerState extends Equatable {
  const ClientMapSeekerState();

  @override
  List<Object?> get props => [];
}

class ClientMapSeekerInitial extends ClientMapSeekerState {}

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
    this.isLoading = false,
    this.originAddress,
    this.destinationAddress,
    this.distanceKm,
    this.durationMinutes,
    this.polylines = const {},
    this.origin,
    this.destination,
    this.timeAndDistanceValues,
    this.createdClientRequest,
    this.clientRequestSended,
    this.isEstimated,
  });

  final Position? userPosition;
  final SelectedField selectedField;
  final Map<String, Marker> driverMarkers;
  final bool isSocketConnected;
  final bool hasCenteredCameraOnce;
  final bool isLoading;
  final String? originAddress;
  final String? destinationAddress;
  final double? distanceKm;
  final int? durationMinutes;
  final Map<PolylineId, Polyline> polylines;
  final LatLng? origin;
  final LatLng? destination;
  final TimeAndDistanceValuesEntity? timeAndDistanceValues;
  final ClientRequestEntity? createdClientRequest;
  final bool? clientRequestSended;
  //boolean to detect if the route is estimated
  final bool? isEstimated;

  ClientMapSeekerSuccess copyWith({
    Position? userPosition,
    SelectedField? selectedField,
    Map<String, Marker>? driverMarkers,
    Set<Polyline>? polylines,
    bool? isSocketConnected,
    bool? hasCenteredCameraOnce,
    bool? isLoading,
    LatLng? origin,
    LatLng? destination,
    String? originAddress,
    String? destinationAddress,
    double? distanceKm,
    int? durationMinutes,
    Map<PolylineId, Polyline>? mapPolylines,
    TimeAndDistanceValuesEntity? timeAndDistanceValues,
    ClientRequestEntity? createdClientRequest,
    bool? clientRequestSended,
    bool? isEstimated,
  }) {
    return ClientMapSeekerSuccess(
      userPosition: userPosition ?? this.userPosition,
      selectedField: selectedField ?? this.selectedField,
      driverMarkers: driverMarkers ?? this.driverMarkers,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      hasCenteredCameraOnce:
          hasCenteredCameraOnce ?? this.hasCenteredCameraOnce,
      isLoading: isLoading ?? this.isLoading,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      polylines: mapPolylines ?? this.polylines,
      timeAndDistanceValues:
          timeAndDistanceValues ?? this.timeAndDistanceValues,
      createdClientRequest: createdClientRequest ?? this.createdClientRequest,
      clientRequestSended: clientRequestSended ?? this.clientRequestSended,
      isEstimated: isEstimated ?? this.isEstimated,
    );
  }

  @override
  List<Object?> get props => [
    userPosition,
    selectedField,
    driverMarkers.values.toList(),
    isSocketConnected,
    hasCenteredCameraOnce,
    isLoading,
    origin,
    destination,
    originAddress,
    destinationAddress,
    distanceKm,
    durationMinutes,
    polylines,
    timeAndDistanceValues,
    createdClientRequest,
    clientRequestSended,
    isEstimated,
  ];
}
