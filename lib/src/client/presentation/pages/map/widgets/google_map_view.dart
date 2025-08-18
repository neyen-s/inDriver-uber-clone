import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/cubit/map_lyfe_cycle_cubit.dart';

class GoogleMapView extends StatelessWidget {
  const GoogleMapView({
    required this.mapController,
    required this.initialPosition,
    required this.markers,
    required this.polylines,
    required this.isTripReady,
    required this.showMapPadding,
    required this.onMapTap,
    super.key,
  });

  final Completer<GoogleMapController> mapController;
  final CameraPosition initialPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool isTripReady;
  final bool showMapPadding;
  final ValueChanged<LatLng> onMapTap;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialPosition,
      style: customMapStyle,
      onMapCreated: (controller) {
        if (!mapController.isCompleted) {
          mapController.complete(controller);
        }
        try {
          context.read<MapLifecycleCubit>().markReady();
        } catch (_) {}
      },
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
        if (!isTripReady) onMapTap(pos);
      },
    );
  }
}
