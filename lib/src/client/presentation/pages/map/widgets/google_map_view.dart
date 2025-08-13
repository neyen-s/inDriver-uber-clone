import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';

class GoogleMapView extends StatelessWidget {
  GoogleMapView({
    required this.mapController,
    required this.initialPosition,
    required this.markers,
    required this.showMapPadding,
    required this.polylines,
    required this.isTripReady,
    this.onIdle,
    this.onMove,
    this.onTap,
    super.key,
  });

  final Completer<GoogleMapController> mapController;
  final CameraPosition initialPosition;
  final Set<Marker> markers;
  final bool showMapPadding;
  final Set<Polyline> polylines;
  final void Function(LatLng target)? onIdle;
  final void Function(LatLng target)? onMove;
  final void Function(LatLng target)? onTap;
  final bool isTripReady;
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialPosition,
      onMapCreated: (controller) {
        if (!mapController.isCompleted) {
          mapController.complete(controller);
        }
      },
      style: customMapStyle,
      padding: showMapPadding
          ? EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.4 + 50,
              top: 100,
              left: 40,
              right: 40,
            )
          : EdgeInsets.zero,
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      polylines: Set.from(polylines),
      onTap: (pos) {
        if (!isTripReady && onTap != null) {
          onTap!(pos);
        }
      },
      onCameraMove: (pos) {
        if (!isTripReady) {
          onMove?.call(pos.target);
        }
      },
      onCameraIdle: () async {
        if (!isTripReady && onIdle != null) {
          final c = await mapController.future;
          await Future.delayed(const Duration(milliseconds: 50));
          final size = MediaQuery.of(context).size;
          final dpr = MediaQuery.of(context).devicePixelRatio;
          final paddingTop = showMapPadding ? 100.0 : 0.0;
          final paddingBottom = showMapPadding
              ? (size.height * 0.4 + 50.0)
              : 0.0;
          final paddingLeft = showMapPadding ? 40.0 : 0.0;
          final paddingRight = showMapPadding ? 40.0 : 0.0;

          final adjustedX =
              ((size.width - paddingLeft - paddingRight) / 2 + paddingLeft);
          final adjustedY =
              ((size.height - paddingTop - paddingBottom) / 2 + paddingTop);

          final screenX = (adjustedX * dpr).round(); // <-- usa screenX
          final screenY = (adjustedY * dpr).round();

          final pos = await c.getLatLng(
            ScreenCoordinate(x: screenX, y: screenY), // <-- corregido
          );
          onIdle!(pos);
        }
      },
    );
  }
}
