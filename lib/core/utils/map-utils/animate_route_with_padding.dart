import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const int maxZoom = 21;
const int minZoom = 2;
const double worldPx = 256;

Future<void> animateRouteWithPadding({
  required GoogleMapController controller,
  required List<LatLng> points,
  required VoidCallback enablePadding,
  required BuildContext context,
  EdgeInsets? desiredMapPadding,
  double verticalBiasFactor = -0.18,
}) async {
  if (points.isEmpty) return;

  //Close the keyboard if it's open
  try {
    FocusScope.of(context).unfocus();
  } catch (_) {}

  enablePadding();
  await Future<void>.delayed(const Duration(milliseconds: 220));

  final size = MediaQuery.of(context).size;
  final mapWidth = size.width;
  final mapHeight = size.height;
  // Calculate the desired padding, using the provided padding or default values
  final desired =
      desiredMapPadding ??
      EdgeInsets.only(
        bottom: mapHeight * 0.40 + 50,
        top: 80,
        left: 30,
        right: 30,
      );

  final leftPad = desired.left;
  final rightPad = desired.right;
  final topPad = desired.top;
  final bottomPad = desired.bottom;

  final availableWidth = max(10, mapWidth - leftPad - rightPad);
  final availableHeight = max(10, mapHeight - topPad - bottomPad);

  final bounds = _getBoundsFromLatLngList(points);
  final north = bounds.northeast.latitude;
  final south = bounds.southwest.latitude;
  final east = bounds.northeast.longitude;
  final west = bounds.southwest.longitude;

  // Calculate the zoom level based on the bounds and available space
  double latRad(double lat) {
    final rad = lat * pi / 180.0;
    return log(tan(rad / 2.0 + pi / 4.0));
  }

  final latFraction = ((latRad(north) - latRad(south)).abs()) / pi;
  var lngDiff = (east - west).abs();
  if (lngDiff > 360) lngDiff = 360;
  if (east < west) lngDiff = (east + 360) - west;
  final lngFraction = (lngDiff / 360.0).clamp(1e-9, 1.0);

  double zoomForLng() {
    final scale = availableWidth / worldPx / lngFraction;
    return log(scale) / ln2;
  }

  double zoomForLat() {
    final latFracSafe = max(latFraction, 1e-9);
    final scale = availableHeight / worldPx / latFracSafe;
    return log(scale) / ln2;
  }

  final zLng = zoomForLng();
  final zLat = zoomForLat();
  double zoom = min(zLng, zLat);
  zoom = zoom.isFinite ? zoom : minZoom.toDouble();
  zoom = zoom.clamp(minZoom.toDouble(), maxZoom.toDouble());

  //vertical adjustment is based on bottomPad and verticalBiasFactor
  // to ensure the route is centered vertically
  final verticalBias =
      (bottomPad / (availableHeight + bottomPad + topPad)).clamp(0.0, 1.0) *
      verticalBiasFactor;
  final desiredFactor = (0.5 - verticalBias).clamp(0.0, 1.0);

  final latSpan = north - south;
  final centerLat = north - latSpan * desiredFactor;

  double centerLng;
  if (east >= west) {
    centerLng = (east + west) / 2.0;
  } else {
    final west360 = (west < 0) ? west + 360.0 : west;
    final east360 = (east < 0) ? east + 360.0 : east;
    final avg360 = (west360 + east360) / 2.0;
    centerLng = (avg360 > 180) ? avg360 - 360.0 : avg360;
  }

  final center = LatLng(centerLat, centerLng);

  try {
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: center, zoom: zoom),
      ),
    );
  } catch (e) {
    debugPrint('[animateRoute] animateCamera failed: $e');
    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: center, zoom: (minZoom + 6).toDouble()),
        ),
      );
    } catch (_) {}
  }
}

LatLngBounds _getBoundsFromLatLngList(List<LatLng> points) {
  assert(points.isNotEmpty, ' LatLng list cannot be empty');
  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;

  for (final p in points) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLng) minLng = p.longitude;
    if (p.longitude > maxLng) maxLng = p.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}
