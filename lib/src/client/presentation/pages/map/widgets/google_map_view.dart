import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';

class GoogleMapView extends StatelessWidget {
  const GoogleMapView({
    required this.mapController,
    required this.initialPosition,
    required this.markers,
    required this.showMapPadding,
    required this.polylines,
    required this.isTripReady,
    this.onIdle,
    this.onMove,
    super.key,
  });

  final Completer<GoogleMapController> mapController;
  final CameraPosition initialPosition;
  final Set<Marker> markers;
  final bool showMapPadding;
  final Set<Polyline> polylines;
  final void Function(LatLng target)? onIdle;
  final void Function(LatLng target)? onMove;
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
      onCameraMove: (pos) {
        if (!isTripReady) {
          onMove?.call(pos.target);
        }
      },
      onCameraIdle: () {
        if (!isTripReady && onIdle != null) {
          mapController.future.then((c) async {
            final size = MediaQuery.of(context).size;
            final paddingTop = showMapPadding ? 100 : 0;
            final paddingBottom = showMapPadding ? (size.height * 0.4 + 50) : 0;
            final adjustedY =
                ((size.height - paddingTop - paddingBottom) / 2 + paddingTop)
                    .round();

            final pos = await c.getLatLng(
              ScreenCoordinate(x: (size.width / 2).round(), y: adjustedY),
            );
            onIdle!(pos);
          });
        }
      },
    );
  }
}
