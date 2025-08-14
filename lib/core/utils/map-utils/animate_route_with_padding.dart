import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> animateRouteWithPadding({
  required GoogleMapController controller,
  required List<LatLng> points,
  required VoidCallback enablePadding,
  required BuildContext context,
  EdgeInsets? desiredMapPadding,
  int maxRetries = 4,
}) async {
  if (points.isEmpty) return;

  // 0) Close keyboard
  try {
    FocusScope.of(context).unfocus();
  } catch (_) {}

  enablePadding();
  await Future<void>.delayed(const Duration(milliseconds: 400));
  await Future(() {});

  final size = MediaQuery.of(context).size;
  final bounds = getBoundsFromLatLngList(points);

  // requested padding based on bottom sheet but not exceeding fraction of the view
  final desired =
      desiredMapPadding ??
      EdgeInsets.only(
        bottom: size.height * 0.30 + 40,
        top: 80,
        left: 30,
        right: 30,
      );
  double requestedPadding = [
    desired.left,
    desired.top,
    desired.right,
    desired.bottom,
  ].reduce(max);

  // Limit to a fraction of the view to keep the route tight
  final safeMax = (min(size.width, size.height) / 2) - 1.0;
  // Use a fraction e.g. 0.18 of min dimension to be device-independent
  final fractionMax = min(safeMax, min(size.width, size.height) * 0.18);
  double currentPadding = requestedPadding.clamp(0.0, fractionMax);

  debugPrint(
    '[animateRoute] bounds NE:${bounds.northeast} SW:${bounds.southwest}',
  );
  debugPrint(
    '[animateRoute] requested logical padding: $requestedPadding clamped-> $currentPadding (fractionMax:$fractionMax)',
  );

  int attempt = 0;
  while (attempt < maxRetries) {
    attempt++;
    try {
      debugPrint(
        '[animateRoute] attempt $attempt -> newLatLngBounds with padding ${currentPadding.round()}',
      );
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, currentPadding.round().toDouble()),
      );
      debugPrint('[animateRoute] success attempt $attempt');
      return;
    } catch (e, st) {
      debugPrint('[animateRoute] newLatLngBounds failed attempt $attempt: $e');
      currentPadding = max(0.0, currentPadding / 2);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
  }

  // fallback: center + zoom
  final center = LatLng(
    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
    (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
  );
  const fallbackZoom = 13.0;
  try {
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: center, zoom: fallbackZoom),
      ),
    );
  } catch (e) {
    debugPrint('[animateRoute] fallback animateCamera failed: $e');
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
