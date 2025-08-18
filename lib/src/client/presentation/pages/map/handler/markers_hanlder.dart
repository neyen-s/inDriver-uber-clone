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

  if (state is PositionWithMarkerSuccess) {
    markers.add(state.marker);
  }

  if (originIcon != null && destinationIcon != null) {
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
