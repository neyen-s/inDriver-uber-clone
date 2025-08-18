import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/map_maker_icon_service.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/build_polyline_from_points.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/calculate_trip_price.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/cubit/map_lyfe_cycle_cubit.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/map_listener_handler.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/markers_hanlder.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/on_map_tap_handler.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/route_confirmation_handler.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/update_loader_hablder.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/confirm_route_btn.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/google_map_search_fields.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/google_map_view.dart';
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
    _loadCustomIcons().then((_) async {
      await _mapController.future;
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<ClientMapSeekerBloc, ClientMapSeekerState>(
            listener: (context, state) async {
              await handleMapStateChange(
                context: context,
                state: state,
                mapController: _mapController,
                pickUpController: _pickUpController,
                destinationController: _destinationController,
                originFocusNode: originFocusNode,
                destinationFocusNode: destinationFocusNode,
                onUpdateSelectedField: (field) => currentSelectedField = field,
                onUpdateOriginLatLng: (lat) => originLatLng = lat,
                onUpdateDestinationLatLng: (lat) => destinationLatLng = lat,
                onSetShowMapPadding: (v) => showMapPadding = v,
              );
              updateLoader(context);
            },
          ),
          BlocListener<MapLifecycleCubit, MapLifecycleState>(
            listener: (context, mapState) {
              updateLoader(context);
            },
          ),
        ],
        child: BlocBuilder<ClientMapSeekerBloc, ClientMapSeekerState>(
          builder: (context, state) {
            final markers = handleMarkers(
              state: state,
              originLatLng: originLatLng,
              destinationLatLng: destinationLatLng,
              originIcon: _originIcon,
              destinationIcon: _destinationIcon,
            );

            final isTripReady = state is TripReadyToDisplay;

            return Stack(
              children: [
                GoogleMapView(
                  mapController: _mapController,
                  initialPosition: _initialPosition,
                  markers: markers,
                  polylines: buildPolylineFromPoints(state),
                  isTripReady: isTripReady,
                  showMapPadding: showMapPadding,
                  onMapTap: onMapTapHandler(
                    context: context,
                    mapController: _mapController,
                    originFocusNode: originFocusNode,
                    destinationFocusNode: destinationFocusNode,
                    originLat: originLatLng,
                    destinationLat: destinationLatLng,
                    onSetOrigin: (latLng) => _handleLocationSelected(
                      context: context,
                      field: SelectedField.origin,
                      latLng: latLng,
                    ),
                    onSetDestination: (latLng) => _handleLocationSelected(
                      context: context,
                      field: SelectedField.destination,
                      latLng: latLng,
                    ),
                  ),
                ),

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
                          state: state,
                          onMoveBySearchChanged: (_) {},
                          onOriginSelected: (latLng) => _handleLocationSelected(
                            context: context,
                            field: SelectedField.origin,
                            latLng: latLng,
                          ),
                          onDestinationSelected: (latLng) =>
                              _handleLocationSelected(
                                context: context,
                                field: SelectedField.destination,
                                latLng: latLng,
                              ),
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
      _originIcon = origin;
      _destinationIcon = destination;
    }
  }

  Future<void> _handleLocationSelected({
    required BuildContext context,
    required SelectedField field,
    required LatLng latLng,
  }) async {
    context.read<ClientMapSeekerBloc>().add(
      ChangeSelectedFieldRequested(field),
    );

    if (field == SelectedField.origin) {
      originLatLng = latLng;
    } else {
      destinationLatLng = latLng;
    }
    await moveCameraTo(controller: _mapController, target: latLng, zoom: 16);

    context.read<ClientMapSeekerBloc>().add(GetAddressFromLatLng(latLng));
  }
}
