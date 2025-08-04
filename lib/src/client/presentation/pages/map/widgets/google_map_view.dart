import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';

class GoogleMapView extends StatelessWidget {
  const GoogleMapView({
    required this.controller,
    required this.initialPosition,
    required this.markers,
    required this.showMapPadding,
    required this.polylines,
    required this.isTripReady,
    this.onIdle,
    this.onMove,
    super.key,
  });

  final Completer<GoogleMapController> controller;
  final CameraPosition initialPosition;
  final Set<Marker> markers;
  final bool showMapPadding;
  final Set<Polyline> polylines;
  final Function(LatLng target)? onIdle;
  final Function(LatLng target)? onMove;
  final bool isTripReady;
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialPosition,
      onMapCreated: controller.complete,
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
          controller.future.then((c) async {
            final pos = await c.getLatLng(
              ScreenCoordinate(
                x: MediaQuery.of(context).size.width ~/ 2,
                y: MediaQuery.of(context).size.height ~/ 2,
              ),
            );
            onIdle!(pos);
          });
        }
      },
    );
  }
}
