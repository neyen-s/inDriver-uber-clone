import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

class ClientMapSeekerPage extends StatefulWidget {
  const ClientMapSeekerPage({super.key});

  static const routeName = '/map-seeker';

  @override
  State<ClientMapSeekerPage> createState() => _ClientMapSeekerPageState();
}

class _ClientMapSeekerPageState extends State<ClientMapSeekerPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: defaultLocation,
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    context.read<ClientMapSeekerBloc>().add(GetCurrentPositionRequested());
    context.read<ClientMapSeekerBloc>().add(
      const LoadCurrentLocationWithMarkerRequested(),
    );
  }

  Future<void> _moveCameraTo(LatLng target, double zoom) async {
    if (!_controller.isCompleted) return;
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientMapSeekerBloc, ClientMapSeekerState>(
        listener: (context, state) async {
          if (state is PositionWithMarkerSuccess) {
            final lat = state.position.latitude;
            final lng = state.position.longitude;

            if (lat.abs() < 0.001 && lng.abs() < 0.001) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Couldnt find your location, try again.'),
                ),
              );
              return;
            }

            await _moveCameraTo(LatLng(lat, lng), 16);
          }

          if (state is ClientMapSeekerError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final markers = <Marker>{};
          if (state is PositionWithMarkerSuccess) {
            markers.add(state.marker);
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: _controller.complete,
                style:
                    '[ { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] }, { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#212121" } ] }, { "featureType": "administrative", "elementType": "geometry", "stylers": [ { "color": "#757575" } ] }, { "featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "administrative.land_parcel", "stylers": [ { "visibility": "off" } ] }, { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#181818" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1b1b1b" } ] }, { "featureType": "road", "elementType": "geometry.fill", "stylers": [ { "color": "#2c2c2c" } ] }, { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#8a8a8a" } ] }, { "featureType": "road.arterial", "elementType": "geometry", "stylers": [ { "color": "#373737" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#3c3c3c" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [ { "color": "#4e4e4e" } ] }, { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#3d3d3d" } ] } ]',
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
              if (state is ClientMapSeekerLoading)
                const Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<ClientMapSeekerBloc>().add(
            const LoadCurrentLocationWithMarkerRequested(),
          );
        },
        label: const Text('Mi ubicación'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }
}
