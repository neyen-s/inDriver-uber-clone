import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/map_maker_icon_service.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/add_markers_on_trip_created.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/animate_route_with_padding.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/build_polyline_from_points.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/calculate_trip_price.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/get_adress_from_latlng.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/route_confirmation_handler.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/center_pin_icon.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/confirm_route_btn.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/google_map_search_fields.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/google_map_view.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/map_loading_indicator.dart';
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
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  bool showMapPadding = false;

  late final MapMarkerIconService _iconService;
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  @override
  void initState() {
    super.initState();
    _iconService = sl<MapMarkerIconService>();
    _loadCustomIcons();
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
            originLatLng = latLng;

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
                originLatLng = state.selectedLatLng;
              case SelectedField.destination:
                _destinationController.text = state.address;
                _destinationController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _destinationController.text.length),
                );
                destinationLatLng = state.selectedLatLng;
            }
          }
          if (state is TripReadyToDisplay) {
            final controller = await _controller.future;

            final latLngPoints = state.polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList();

            await animateRouteWithPadding(
              controller: controller,
              points: latLngPoints,
              enablePadding: () => setState(() => showMapPadding = true),
            );
          } else {
            setState(() {
              showMapPadding = false;
            });
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
          if (_originIcon != null && _destinationIcon != null) {
            addMarkersOnTripCreated(
              state: state,
              markers: markers,
              originIcon: _originIcon,
              destinationIcon: _destinationIcon,
              originLatLng: originLatLng,
              destinationLatLng: destinationLatLng,
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTripReady = state is TripReadyToDisplay;

              return SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    GoogleMapView(
                      controller: _controller,
                      initialPosition: _initialPosition,
                      markers: markers,
                      showMapPadding: showMapPadding,
                      polylines: buildPolylineFromPoints(state),
                      isTripReady: isTripReady,
                      onMove: (pos) => _cameraTarget = pos,
                      onIdle: (LatLng pos) {
                        context.read<ClientMapSeekerBloc>().add(MapIdle(pos));
                      },
                    ),
                    if (state is ClientMapSeekerLoading) MapLoadingIndicator(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),

                      child: isTripReady
                          ? const SizedBox.shrink()
                          : GoogleMapSearchFields(
                              controller: _controller,
                              pickUpController: _pickUpController,
                              destinationController: _destinationController,
                              originFocusNode: originFocusNode,
                              destinationFocusNode: destinationFocusNode,
                              moveBySearch: _moveBySearch,
                              state: state,
                            ),
                    ),
                    if (!isTripReady)
                      ConfirmRouteBtn(
                        onPressed: () => handleRouteConfirmation(
                          context: context,
                          originText: _pickUpController.text,
                          destinationText: _destinationController.text,
                          originLatLng: originLatLng,
                          destinationLatLng: destinationLatLng,
                          fallbackOrigin: originLatLng,
                          fallbackDestination: destinationLatLng,
                          onSuccess: () => setState(() => _cameraTarget = null),
                        ),
                      ),
                    if (!isTripReady)
                      const CenterPinIcon()
                    else
                      const SizedBox.shrink(),
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
            child: state is TripReadyToDisplay
                ? TripSummaryCard(
                    context: context,
                    originAddress: state.origin,
                    destinationAddress: state.destination,
                    distanceInKm: state.distanceKm,
                    duration: Duration(minutes: state.durationMinutes),
                    price: calculateTripPrice(
                      state.distanceKm,
                      state.durationMinutes,
                    ),
                    onCancelPressed: () {
                      context.read<ClientMapSeekerBloc>().add(
                        const CancelTripConfirmation(),
                      );
                    },
                    onConfirmPressed: (offer) {},
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Future<void> _loadCustomIcons() async {
    final iconService = sl<MapMarkerIconService>();
    final origin = await iconService.getOriginIcon();
    final destination = await iconService.getDestinationIcon();

    if (mounted) {
      setState(() {
        _originIcon = origin;
        _destinationIcon = destination;
      });
    }
  }
}
