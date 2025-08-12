import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';

import 'package:indriver_uber_clone/src/driver/presentation/pages/map/bloc/driver_map_bloc.dart';

class DriverMapPage extends StatefulWidget {
  const DriverMapPage({super.key});
  static const String routeName = 'driver/map';

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  late Completer<GoogleMapController> _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: defaultLocation,
    zoom: 14,
  );
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    print('------------DriverMapPage initialized------------');
    _mapController = Completer<GoogleMapController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverMapBloc>().add(const DriverLocationStreamStarted());
    });
  }

  @override
  void dispose() {
    _mapController.future.then((controller) {
      controller.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DriverMapBloc, DriverMapState>(
        listener: (context, state) async {
          print('DriverMapPage Listener: $state');
          if (state is DriverMapPositionWithMarker) {
            await _updateMarkerAndCamera(state.marker);
          }
          if (state is DriverMapError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: GoogleMap(
          style: customMapStyle,
          initialCameraPosition: _initialPosition,
          markers: _markers,
          myLocationEnabled: true,
          onMapCreated: (controller) async {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
        ),
      ),
    );
  }

  Future<void> _updateMarkerAndCamera(Marker marker) async {
    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..add(marker);
    });

    final controller = await _mapController.future;
    await moveCameraTo(controller: _mapController, target: marker.position);
  }
}
