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
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/update_loader_handler.dart';
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
              // Si ya migraste a ClientMapSeekerSuccess, extrae los valores desde ahí
              if (state is ClientMapSeekerSuccess) {
                // si tienes un helper que espera el state antiguo, puedes adaptarlo,
                // pero aquí llamamos al handler con los datos concretos:
                await handleMapStateChange(
                  context: context,
                  state:
                      state, // si tu helper usa el state, adapta su implementación para ClientMapSeekerSuccess
                  mapController: _mapController,
                  pickUpController: _pickUpController,
                  destinationController: _destinationController,
                  originFocusNode: originFocusNode,
                  destinationFocusNode: destinationFocusNode,
                  onUpdateSelectedField: (field) =>
                      currentSelectedField = field,
                  onUpdateOriginLatLng: (lat) => originLatLng = lat,
                  onUpdateDestinationLatLng: (lat) => destinationLatLng = lat,
                  onSetShowMapPadding: (v) => showMapPadding = v,
                );
              } else {
                // Si aún estás con estados antiguos, mantenemos la llamada original
                await handleMapStateChange(
                  context: context,
                  state: state,
                  mapController: _mapController,
                  pickUpController: _pickUpController,
                  destinationController: _destinationController,
                  originFocusNode: originFocusNode,
                  destinationFocusNode: destinationFocusNode,
                  onUpdateSelectedField: (field) =>
                      currentSelectedField = field,
                  onUpdateOriginLatLng: (lat) => originLatLng = lat,
                  onUpdateDestinationLatLng: (lat) => destinationLatLng = lat,
                  onSetShowMapPadding: (v) => showMapPadding = v,
                );
              }

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
            // Si está migrado, usa datos del success
            Set<Marker> markersFromState = {};
            Set<Polyline> polylinesFromState = {};
            bool isTripReady = false;

            if (state is ClientMapSeekerSuccess) {
              // markers
              markersFromState = handleMarkers(
                state: state,
                originLatLng: originLatLng,
                destinationLatLng: destinationLatLng,
                originIcon: _originIcon,
                destinationIcon: _destinationIcon,
              );

              // polylines (ruta)
              polylinesFromState = buildPolylineFromPoints(state);

              // ahora el flag se basa en si hay polylines
              isTripReady = polylinesFromState.isNotEmpty;
            }

            return Stack(
              children: [
                GoogleMapView(
                  mapController: _mapController,
                  initialPosition: _initialPosition,
                  markers: markersFromState,
                  polylines: polylinesFromState,
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
                    onPressed: () {
                      if (originLatLng != null && destinationLatLng != null) {
                        context.read<ClientMapSeekerBloc>().add(
                          DrawRouteRequested(
                            origin: originLatLng!,
                            destination: destinationLatLng!,
                            originText: _pickUpController.text,
                            destinationText: _destinationController.text,
                          ),
                        );
                      }
                    },
                  ),
              ],
            );
          },
        ),
      ),
      bottomSheet: BlocBuilder<ClientMapSeekerBloc, ClientMapSeekerState>(
        builder: (context, state) {
          print(
            ' state.distanceKm  --> ${state is ClientMapSeekerSuccess ? state.distanceKm : ''} ',
          );
          print(
            ' state.durationMinutes  --> ${state is ClientMapSeekerSuccess ? state.durationMinutes : ''}',
          );
          print(
            ' state.polylines.isNotEmpty  --> ${state is ClientMapSeekerSuccess ? state.polylines.isNotEmpty : ''}',
          );

          // Si migrado, intenta leer desde Success (añade campos de trip si los metes en Success)
          if (state is ClientMapSeekerSuccess &&
              state.distanceKm != null &&
              state.durationMinutes != null &&
              state.polylines.isNotEmpty) {
            // TODO CHECK POLYLINES VARIABLE
            print('*************************************** entro ***');
            return TripSummaryCard(
              context: context,
              originAddress: state.originAddress ?? '',
              destinationAddress: state.destinationAddress ?? '',
              distanceInKm: state.distanceKm ?? 0.0,
              duration: Duration(minutes: state.durationMinutes ?? 0),
              price: calculateTripPrice(
                state.distanceKm ?? 0.0,
                state.durationMinutes ?? 0,
              ),
              onCancelPressed: () {
                context.read<ClientMapSeekerBloc>().add(
                  const CancelTripConfirmation(),
                );
              },
              onConfirmPressed: (offer) {},
            );
          }
          return const SizedBox.shrink();
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
    if (field == SelectedField.origin) {
      originLatLng = latLng;
    } else {
      destinationLatLng = latLng;
    }
    await moveCameraTo(controller: _mapController, target: latLng, zoom: 16);
    context.read<ClientMapSeekerBloc>().add(
      GetAddressFromLatLng(latLng, selectedField: field),
    );
  }
}
