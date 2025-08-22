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

  // Origin / Destination markers (si están disponibles)
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

  // Si el state es el nuevo state "rico", usamos sus driverMarkers
  if (state is ClientMapSeekerSuccess) {
    // driverMarkers ya es un Set<Marker> según el state migrado
    markers.addAll(state.driverMarkers);
  }

  // Compatibilidad por si queda un state antiguo con marker único
  /*   if (state is PositionWithMarkerSuccess) {
    markers.add(state.marker);
  } */

  // Si existe una ruta (mapPolylines no vacía) o si el estado antiguo tenía TripReady,
  // delegamos a addMarkersOnTripCreated (mantengo la llamada para no romper lógica previa)
  final hasRoute =
      (state is ClientMapSeekerSuccess && state.polylines.isNotEmpty) /*  ||
      (state is TripReadyToDisplay) */;

  if (hasRoute && originIcon != null && destinationIcon != null) {
    // addMarkersOnTripCreated espera el state original (ClientMapSeekerState) —
    // como ClientMapSeekerSuccess extiende ese tipo, está bien pasar `state`.
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
