import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

Set<Polyline> buildPolylineFromPoints(ClientMapSeekerState state) {
  // Si usas el nuevo estado con mapPolylines (Map<PolylineId, Polyline>)
  if (state is ClientMapSeekerSuccess) {
    if (state.polylines.isEmpty) return {};

    // Retornamos todas las polylines almacenadas
    return state.polylines.values.toSet();
  }

  // Compatibilidad con antiguo TripReadyToDisplay (si aún existe)
  /*   if (state is TripReadyToDisplay) {
    final latLngPoints = state.polylinePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 4,
        points: latLngPoints,
      ),
    };
  } */

  return {};
}
