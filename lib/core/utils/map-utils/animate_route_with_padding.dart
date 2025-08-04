import 'dart:async';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> animateRouteWithPadding({
  required GoogleMapController controller,
  required List<LatLng> points,
  required VoidCallback enablePadding,
}) async {
  if (points.isEmpty) return;

  enablePadding();

  await Future<void>.delayed(const Duration(milliseconds: 50));
  await Future(() {});

  final bounds = getBoundsFromLatLngList(points);

  try {
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: points.first, zoom: 10),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 100));

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, -40));
  } catch (e) {
    print('Camera animation failed: $e');
  }
}

LatLngBounds getBoundsFromLatLngList(List<LatLng> points) {
  assert(points.isNotEmpty, 'List of points cannot be empty');

  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;

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
