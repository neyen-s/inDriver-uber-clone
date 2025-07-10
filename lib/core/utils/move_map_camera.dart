import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> moveCameraTo({
  required Completer<GoogleMapController> controller,
  required LatLng target,
  double zoom = 14,
}) async {
  if (!controller.isCompleted) return;
  final mapController = await controller.future;
  await mapController.animateCamera(
    CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)),
  );
}
