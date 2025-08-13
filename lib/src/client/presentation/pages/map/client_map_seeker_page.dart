import 'dart:async';
import 'dart:math';

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
  late Completer<GoogleMapController> _mapController;

  final TextEditingController _pickUpController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  static const CameraPosition _initialPosition = CameraPosition(
    target: defaultLocation,
    zoom: 14,
  );

  final originFocusNode = FocusNode();
  final destinationFocusNode = FocusNode();
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  bool showMapPadding = false;

  SelectedField currentSelectedField = SelectedField.origin;

  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  @override
  void initState() {
    super.initState();
    _mapController = Completer();
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
    _mapController.future
        .then((controller) {
          controller.dispose();
        })
        .catchError((_) {});
    _mapController = Completer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientMapSeekerBloc, ClientMapSeekerState>(
        listener: (context, state) async {
          if (state is SelectedFieldChanged) {
            setState(() {
              currentSelectedField = state.selectedField;
            });
          }

          // 1º Centers the map on the current position
          // and updates the origin address
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
              controller: _mapController,
              target: latLng,
              zoom: 16,
            );
            originLatLng = latLng;
            setState(() {});
            final address = await getAddressFromLatLng(latLng);
            _pickUpController.text = address;
          }

          // 2º Updates the map camera position
          if (state is AddressUpdatedSuccess) {
            // Si venimos de una búsqueda marcada por el parent, no sobrescribimos
            /*           if (_moveBySearch) {
              _moveBySearch = false; // limpiamos el flag y salimos
              return;
            } */
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
          // 3º If the trip is ready to display,
          // animate the route and set LatLng points
          if (state is TripReadyToDisplay) {
            final controller = await _mapController.future;

            final latLngPoints = state.polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList();

            await animateRouteWithPadding(
              controller: controller,
              points: latLngPoints,
              enablePadding: () => setState(() => showMapPadding = true),
            );
          } else {
            if (!mounted) return;
            setState(() {
              showMapPadding = false;
            });
          }
          // 4º Errors
          if (state is ClientMapSeekerError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final markers = <Marker>{};

          if (originLatLng != null && _originIcon != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('origin'),
                position: originLatLng!,
                icon: _originIcon!,
              ),
            );
          }

          if (destinationLatLng != null && _destinationIcon != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('destination'),
                position: destinationLatLng!,
                icon: _destinationIcon!,
              ),
            );
          }

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
          final isTripReady = state is TripReadyToDisplay;

          return Stack(
            children: [
              GoogleMapView(
                mapController: _mapController,
                initialPosition: _initialPosition,
                markers: markers,

                polylines: buildPolylineFromPoints(state),
                isTripReady: isTripReady,
                showMapPadding:
                    showMapPadding, // asegúrate de exponerlo en GoogleMapView
                onMapTap: (LatLng tapped) async {
                  // Decide si el tap va a origen o destino
                  SelectedField targetField;
                  if (originFocusNode.hasFocus) {
                    targetField = SelectedField.origin;
                  } else if (destinationFocusNode.hasFocus) {
                    targetField = SelectedField.destination;
                  } else {
                    // Si no hay foco: si aún no hay origen, usar origen; si ya hay origen, usar destino
                    targetField = (originLatLng == null)
                        ? SelectedField.origin
                        : SelectedField.destination;
                    // sincroniza el bloc con el campo elegido
                    context.read<ClientMapSeekerBloc>().add(
                      ChangeSelectedFieldRequested(targetField),
                    );
                  }

                  if (targetField == SelectedField.origin) {
                    originLatLng = tapped;
                  } else {
                    destinationLatLng = tapped;
                  }

                  // Move camera (opcional, para centrar)
                  await moveCameraTo(
                    controller: _mapController,
                    target: tapped,
                    zoom: 16,
                  );

                  // Pide la dirección según el campo seleccionado en el bloc
                  context.read<ClientMapSeekerBloc>().add(
                    GetAddressFromLatLng(tapped),
                  );
                },
              ),

              if (state is ClientMapSeekerLoading) const MapLoadingIndicator(),

              // Search fields
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isTripReady
                    ? const SizedBox.shrink()
                    : GoogleMapSearchFields(
                        controller: _mapController,
                        pickUpController: _pickUpController,
                        destinationController: _destinationController,
                        isOriginSelected:
                            currentSelectedField == SelectedField.origin,
                        isDestinationSelected:
                            currentSelectedField == SelectedField.destination,
                        originFocusNode: originFocusNode,
                        destinationFocusNode: destinationFocusNode,
                        moveBySearch:
                            false, // ya no necesitamos gatear por onIdle
                        state: state,
                        onMoveBySearchChanged: (_) {}, // noop
                        onOriginSelected: (LatLng latLng) async {
                          // Marcar campo en bloc y actualizar
                          context.read<ClientMapSeekerBloc>().add(
                            const ChangeSelectedFieldRequested(
                              SelectedField.origin,
                            ),
                          );
                          originLatLng = latLng;

                          await moveCameraTo(
                            controller: _mapController,
                            target: latLng,
                            zoom: 16,
                          );

                          context.read<ClientMapSeekerBloc>().add(
                            GetAddressFromLatLng(latLng),
                          );
                        },
                        onDestinationSelected: (LatLng latLng) async {
                          context.read<ClientMapSeekerBloc>().add(
                            const ChangeSelectedFieldRequested(
                              SelectedField.destination,
                            ),
                          );
                          destinationLatLng = latLng;

                          await moveCameraTo(
                            controller: _mapController,
                            target: latLng,
                            zoom: 16,
                          );

                          context.read<ClientMapSeekerBloc>().add(
                            GetAddressFromLatLng(latLng),
                          );
                        },
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
                    onSuccess: () {
                      if (!mounted) return;
                      // cualquier limpieza local si quieres
                    },
                  ),
                ),
            ],
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
