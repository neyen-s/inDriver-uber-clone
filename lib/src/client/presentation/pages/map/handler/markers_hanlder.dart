import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/add_markers_on_trip_created.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

Set<Marker> handleMarkers({
  required dynamic state,
  required LatLng? originLatLng,
  required LatLng? destinationLatLng,
  required BitmapDescriptor? originIcon,
  required BitmapDescriptor? destinationIcon,
}) {
  final markers = <Marker>{};

  // Origin / Destination markers (if available)
  if (originLatLng != null && originIcon != null) {
    markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: originLatLng,
        icon: originIcon,
      ),
    );
  }

  if (destinationLatLng != null && destinationIcon != null) {
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destinationLatLng,
        icon: destinationIcon,
      ),
    );
  }

  if (state is ClientMapSeekerSuccess) {
    markers.addAll(state.driverMarkers);
  }

  final hasRoute =
      state is ClientMapSeekerSuccess && state.polylines.isNotEmpty;

  //Created the markers If we have a route
  //and we have origin and destination icons
  if (hasRoute && originIcon != null && destinationIcon != null) {
    addMarkersOnTripCreated(
      state: state as ClientMapSeekerState,
      markers: markers,
      originIcon: originIcon,
      destinationIcon: destinationIcon,
      originLatLng: originLatLng,
      destinationLatLng: destinationLatLng,
    );
  }

  return markers;
}
