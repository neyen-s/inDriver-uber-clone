import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

void addMarkersOnTripCreated({
  required ClientMapSeekerState state,
  required Set<Marker> markers,
  required BitmapDescriptor? originIcon,
  required BitmapDescriptor? destinationIcon,
  required LatLng? originLatLng,
  required LatLng? destinationLatLng,
}) {
  // Si estás usando el nuevo estado rico:
  if (state is ClientMapSeekerSuccess) {
    // Si mapPolylines no está vacío consideramos que hay una ruta
    if (state.polylines.isNotEmpty &&
        originLatLng != null &&
        destinationLatLng != null) {
      markers.addAll([
        Marker(
          markerId: const MarkerId('origin'),
          position: originLatLng,
          icon: originIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: 'Origin'),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: destinationLatLng,
          icon: destinationIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      ]);
    }
    return;
  }

  // Compatibilidad con estado antiguo (si todavía lo tuvieses)
}
