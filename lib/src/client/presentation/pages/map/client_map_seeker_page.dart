import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/map_maker_icon_service.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/calculate_trip_price.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/cubit/map_lyfe_cycle_cubit.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/map_listener_handler.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/markers_hanlder.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/handler/on_map_tap_handler.dart';
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
  late SocketBloc _socketBloc;

  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  @override
  void initState() {
    super.initState();
    _mapController = Completer();
    print('--------------entro en client map sekeeer-----');

    // _socketBloc = context.read<SocketBloc>();

    /*     WidgetsBinding.instance.addPostFrameCallback((_) {
     // _socketBloc.add(ConnectSocket());
    }); */

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
    /*     _socketBloc.add(DisconnectSocket());
    try {
      context.read<ClientMapSeekerBloc>().add(const ClearDriverMarkers());
    } catch (_) {} */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ClientMapSeekerBloc, ClientMapSeekerState>(
            listener: (context, state) async {
              if (state is ClientMapSeekerSuccess) {
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
            var markersFromState = <Marker>{};

            var polylinesFromState = <Polyline>{};
            var isTripReady = false;

            if (state is ClientMapSeekerSuccess) {
              debugPrint(
                'UI sees driverMarkers count: ${state.driverMarkers.length}',
              );
              /*         debugPrint(
                'UI driverMarkers ids: ${state.driverMarkers.map((m) => m.markerId.value).toList()}',
              ); */
              // markers
              markersFromState = {
                ...handleMarkers(
                  state: state,
                  originLatLng: originLatLng,
                  destinationLatLng: destinationLatLng,
                  originIcon: _originIcon,
                  destinationIcon: _destinationIcon,
                ),
                ...state.driverMarkers.values.toSet(),
              };

              polylinesFromState = state.polylines.values.toSet();

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
          if (state is ClientMapSeekerSuccess &&
              state.distanceKm != null &&
              state.durationMinutes != null &&
              state.polylines.isNotEmpty) {
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
