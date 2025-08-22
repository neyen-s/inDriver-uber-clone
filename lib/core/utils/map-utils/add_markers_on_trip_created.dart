import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

void addMarkersOnTripCreated({
  required ClientMapSeekerState state,
  required Set<Marker> markers,
  required BitmapDescriptor originIcon,
  required BitmapDescriptor destinationIcon,
  required LatLng? originLatLng,
  required LatLng? destinationLatLng,
}) {
  if (state is ClientMapSeekerSuccess) {
    if (state.polylines.isNotEmpty &&
        originLatLng != null &&
        destinationLatLng != null) {
      markers.addAll([
        Marker(
          markerId: const MarkerId('origin'),
          position: originLatLng,
          icon: originIcon,
          infoWindow: const InfoWindow(title: 'Origin'),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: destinationLatLng,
          icon: destinationIcon,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      ]);
    }
    return;
  }
}
