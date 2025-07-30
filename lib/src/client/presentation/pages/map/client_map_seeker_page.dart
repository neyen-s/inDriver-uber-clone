import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/common/widgets/google_places_auto_complete.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/core/utils/get_adress_from_latlng.dart';
import 'package:indriver_uber_clone/core/utils/move_map_camera.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/trip_summary_card.dart';

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
  bool _moveBySearch = false;

  final originFocusNode = FocusNode();
  final destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientMapSeekerBloc>().add(GetCurrentPositionRequested());
    });

    originFocusNode.addListener(() {
      if (originFocusNode.hasFocus) {
        context.read<ClientMapSeekerBloc>().add(
          const ChangeSelectedFieldRequested(SelectedField.origin),
        );
      }
    });

    destinationFocusNode.addListener(() {
      if (destinationFocusNode.hasFocus) {
        context.read<ClientMapSeekerBloc>().add(
          const ChangeSelectedFieldRequested(SelectedField.destination),
        );
      }
    });
  }

  @override
  void dispose() {
    _pickUpController.dispose();
    _destinationController.dispose();
    originFocusNode.dispose();
    destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientMapSeekerBloc, ClientMapSeekerState>(
        listener: (context, state) async {
          if (state is FindPositionSuccess) {
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
          if (state is AddressUpdatedSuccess) {
            if (_moveBySearch) {
              _moveBySearch = false;
              return;
            }

            switch (state.field) {
              case SelectedField.origin:
                _pickUpController.text = state.address;
                _pickUpController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _pickUpController.text.length),
                );
              case SelectedField.destination:
                _destinationController.text = state.address;
                _destinationController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _destinationController.text.length),
                );
            }
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
              final isConfirmState = state is ReadyToConfirmTrip;

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
                        if (!isConfirmState) {
                          _cameraTarget = position.target;
                        }
                      },
                      onCameraIdle: () {
                        if (!isConfirmState && _cameraTarget != null) {
                          context.read<ClientMapSeekerBloc>().add(
                            MapIdle(_cameraTarget!),
                          );
                        }
                      },
                    ),
                    if (state is ClientMapSeekerLoading)
                      const Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),

                      child: isConfirmState
                          ? const SizedBox.shrink()
                          : Container(
                              key: const ValueKey('search_fields'),
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
                                      focusNode: originFocusNode,
                                      onPlaceSelected: (latLng) {
                                        _moveBySearch = true;
                                        moveCameraTo(
                                          controller: _controller,
                                          target: latLng,
                                          zoom: 16,
                                        );
                                      },
                                      suffixIcon:
                                          state is AddressFetching &&
                                              originFocusNode.hasFocus
                                          ? Padding(
                                              padding: EdgeInsets.all(12.r),
                                              child: SizedBox(
                                                width: 16.w,
                                                height: 16.h,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.w,
                                                    ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    SizedBox(height: 5.h),
                                    GooglePlaceAutocompleteField(
                                      controller: _destinationController,
                                      hintText: 'Destination address',
                                      focusNode: destinationFocusNode,
                                      onPlaceSelected: (latLng) => moveCameraTo(
                                        controller: _controller,
                                        target: latLng,
                                        zoom: 16,
                                      ),
                                      suffixIcon:
                                          state is AddressFetching &&
                                              destinationFocusNode.hasFocus
                                          ? Padding(
                                              padding: EdgeInsets.all(12.r),
                                              child: SizedBox(
                                                width: 16.w,
                                                height: 16.h,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.w,
                                                    ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    if (!isConfirmState)
                      Positioned(
                        bottom: 30.h,
                        left: 20.w,
                        right: 20.w,
                        child: ElevatedButton(
                          onPressed: () {
                            final origin = _pickUpController.text.trim();
                            final destination = _destinationController.text
                                .trim();

                            if (origin.isNotEmpty && destination.isNotEmpty) {
                              setState(() {
                                _cameraTarget = null;
                              });
                              context.read<ClientMapSeekerBloc>().add(
                                ConfirmTripDataEntered(
                                  origin: origin,
                                  destination: destination,
                                ),
                              );
                            }
                          },
                          child: const Text('Confirm destination'),
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
      bottomSheet: BlocBuilder<ClientMapSeekerBloc, ClientMapSeekerState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state is ReadyToConfirmTrip
                ? TripSummaryCard(
                    context: context,
                    originAddress: _pickUpController.text,
                    destinationAddress: _destinationController.text,
                    distanceInKm: 4.2, // Ejemplo
                    duration: const Duration(minutes: 12),
                    price: 6.50,
                    onCancelPressed: () {
                      context.read<ClientMapSeekerBloc>().add(
                        const CancelTripConfirmation(),
                      );
                    },
                    onConfirmPressed: () {
                      // Aquí lanzas un nuevo evento tipo: StartDriverSearch()
                    },
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
