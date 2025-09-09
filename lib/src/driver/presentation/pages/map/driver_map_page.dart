import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
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
  late DriverMapBloc _driverMapBloc;
  late SocketBloc _socketBloc;

  @override
  void initState() {
    super.initState();
    print('------DriverMapPage initState------');
    _driverMapBloc = context.read<DriverMapBloc>();
    // _socketBloc = context.read<SocketBloc>();
    _mapController = Completer<GoogleMapController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_socketBloc.add(ConnectSocket());
      print('Calling Driver Location Stream from drver map page');
      _driverMapBloc.add(const DriverLocationStreamStarted());
    });
  }

  @override
  void dispose() {
    _mapController.future.then((controller) {
      controller.dispose();
    });
    //  _socketBloc.add(DisconnectSocket());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DriverMapBloc, DriverMapState>(
        listener: (context, state) async {
          if (state is DriverMapLoaded) {
            await _updateMarkerAndCamera(state.markers.first);
          }
          if (state is DriverMapError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Stack(
          children: [
            GoogleMap(
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
            Positioned(
              bottom: 20,
              child: ElevatedButton(
                onPressed: () {
                  //print('ConnectSocketIo');
                },
                child: const Text('socket test'),
              ),
            ),
          ],
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

    await _mapController.future;
    await moveCameraTo(controller: _mapController, target: marker.position);
  }
}
