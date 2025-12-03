import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/map_maker_icon_service.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/animate_route_with_padding.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/bloc/client_map_trip_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/widgets/map_trip_details.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/widgets/google_map_view.dart';

class ClientMapTripContent extends StatefulWidget {
  const ClientMapTripContent({super.key});

  @override
  State<ClientMapTripContent> createState() => _ClientMapTripContentState();
}

class _ClientMapTripContentState extends State<ClientMapTripContent> {
  late Completer<GoogleMapController> _mapController;
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  @override
  void initState() {
    super.initState();
    _mapController = Completer();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    final iconService = sl<MapMarkerIconService>();
    _originIcon = await iconService.getOriginIcon();
    _destinationIcon = await iconService.getDestinationIcon();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientMapTripBloc, ClientMapTripState>(
      listenWhen: (prev, curr) => prev.polylines != curr.polylines,

      listener: (context, state) async {
        if (state.polylines.isNotEmpty) {
          try {
            final controller = await _mapController.future;
            final firstPolyline = state.polylines.values.first;
            final latLngPoints = firstPolyline.points;
            await animateRouteWithPadding(
              controller: controller,
              context: context,
              points: latLngPoints,
              enablePadding: () {},
            );
          } catch (e) {
            debugPrint('Error animating route in trip: $e');
          }
        }
      },
      builder: (context, state) {
        final markers = <Marker>{};

        if (state.origin != null && _originIcon != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('origin'),
              position: state.origin!,
              icon: _originIcon!,
            ),
          );
        }

        if (state.destination != null && _destinationIcon != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: state.destination!,
              icon: _destinationIcon!,
            ),
          );
        }

        if (state.driverMarker != null) {
          markers.add(state.driverMarker!);
        }

        return Stack(
          children: [
            GoogleMapView(
              mapController: _mapController,
              initialPosition: CameraPosition(
                target:
                    state.driverMarker?.position ??
                    state.origin ??
                    defaultLocation,
                zoom: 14,
              ),
              markers: markers,
              polylines: state.polylines.values.toSet(),
              isTripReady: state.polylines.isNotEmpty,
              showMapPadding: state.polylines.isNotEmpty,
              onMapTap: (_) {},
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: state.clientRequestResponse != null
                  ? ClientMapTripDetails(
                      clientRequest: state.clientRequestResponse!,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
