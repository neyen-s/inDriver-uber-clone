import 'dart:async';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/get_bounds_from_points.dart';

Future<void> animateRouteWithPadding({
  required GoogleMapController controller,
  required List<LatLng> points,
  required VoidCallback enablePadding,
}) async {
  if (points.isEmpty) return;

  enablePadding();

  await Future.delayed(const Duration(milliseconds: 50));
  await Future(() {});

  final bounds = getBoundsFromLatLngList(points);

  try {
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: points.first, zoom: 10),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, -40));
  } catch (e) {
    print('Camera animation failed: $e');
  }
}
