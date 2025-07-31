import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double getMapPadding(EdgeInsets padding) {
  final maxPadding = [
    padding.left,
    padding.top,
    padding.right,
    padding.bottom,
  ].reduce((a, b) => a > b ? a : b);

  // Limitar el padding a 200 como máximo (en px)
  return maxPadding.clamp(0, 200);
}

LatLngBounds getBoundsFromLatLngList(List<LatLng> points) {
  assert(points.isNotEmpty);

  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;

  for (final point in points) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

int calculateDynamicPadding({
  required double screenHeight,
  required double distanceKm,
}) {
  const minPadding = 50;
  const maxPadding = 100;

  // Rutas cortas (menos de 0.5 km): damos más padding para que no se tape
  if (distanceKm < 0.5) return 250;

  // Rutas largas (más de 10 km): menos padding
  if (distanceKm > 10) return minPadding;

  // Interpolación lineal entre min y max
  final interpolated =
      maxPadding - ((distanceKm / 10) * (maxPadding - minPadding));
  return interpolated.toInt().clamp(minPadding, 250);
}

Future<void> animateRouteOnMap({
  required BuildContext context,
  required GoogleMapController controller,
  required List<LatLng> points,
}) async {
  if (points.length < 2) return;

  final bounds = getBoundsFromLatLngList(points);

  try {
    /*  await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: midpoint, zoom: zoomLevel),
      ),
    ); */

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, -40), // tu valor ajustado
    );
  } catch (e) {
    print('Camera update failed: $e');
  }
}

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295; // pi / 180
  final a =
      0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
}
