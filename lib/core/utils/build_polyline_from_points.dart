import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

Set<Polyline> buildPolylineFromPoints(ClientMapSeekerState state) {
  if (state is TripReadyToDisplay) {
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
  }
  return {};
}
