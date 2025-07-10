import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/common/widgets/google_places_auto_complete.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/core/utils/get_adress_from_latlng.dart';
import 'package:indriver_uber_clone/core/utils/move_map_camera.dart';
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

  final TextEditingController _pickUpController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  static const CameraPosition _initialPosition = CameraPosition(
    target: defaultLocation,
    zoom: 14,
  );

  LatLng? _cameraTarget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientMapSeekerBloc>().add(
        const LoadCurrentLocationWithMarkerRequested(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientMapSeekerBloc, ClientMapSeekerState>(
        listener: (context, state) async {
          print(' state is: $state');
          if (state is PositionWithMarkerSuccess) {
            final position = state.position;
            final latLng = LatLng(position.latitude, position.longitude);

            if (position.latitude.abs() < 0.001 &&
                position.longitude.abs() < 0.001) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Couldn't find your location, try again."),
                ),
              );
              return;
            }

            await moveCameraTo(
              controller: _controller,
              target: latLng,
              zoom: 16,
            );

            final address = await getAddressFromLatLng(latLng);
            _pickUpController.text = address;
            print('Address: $address');
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

          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialPosition,
                      onMapCreated: _controller.complete,
                      style: customMapStyle,
                      markers: markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onCameraMove: (position) {
                        context.read<ClientMapSeekerBloc>().add(
                          MapMoved(position.target),
                        );
                      },
                      onCameraIdle: () {
                        context.read<ClientMapSeekerBloc>().add(
                          const MapIdle(),
                        );
                      },
                    ),
                    if (state is ClientMapSeekerLoading)
                      const Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    Container(
                      height: 120.h,
                      margin: EdgeInsets.only(
                        top: 20.h,
                        left: 20.w,
                        right: 20.w,
                      ),
                      alignment: Alignment.center,
                      child: Card(
                        surfaceTintColor: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GooglePlaceAutocompleteField(
                              controller: _pickUpController,
                              hintText: 'Pick up address',
                              onPlaceSelected: (latLng) => moveCameraTo(
                                controller: _controller,
                                target: latLng,
                                zoom: 16,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            GooglePlaceAutocompleteField(
                              controller: _destinationController,
                              hintText: 'Destination address',
                              onPlaceSelected: (latLng) => moveCameraTo(
                                controller: _controller,
                                target: latLng,
                                zoom: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Image.asset(
                        'assets/img/location_blue.png',
                        width: 40.w,
                        height: 40.h,
                      ),
                    ),
                  ],
                ),
              );
            },
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
