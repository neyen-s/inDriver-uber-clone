import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/animate_route_with_padding.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/get_adress_from_latlng.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/driver-offers/client_driver_offers_page.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

Future<void> handleMapStateChange({
  required BuildContext context,
  required ClientMapSeekerState state,
  required Completer<GoogleMapController> mapController,
  required TextEditingController pickUpController,
  required TextEditingController destinationController,
  required FocusNode originFocusNode,
  required FocusNode destinationFocusNode,
  required void Function(SelectedField) onUpdateSelectedField,
  required void Function(LatLng?) onUpdateOriginLatLng,
  required void Function(LatLng?) onUpdateDestinationLatLng,
  required void Function(bool) onSetShowMapPadding,
}) async {
  if (state is ClientMapSeekerSuccess) {
    debugPrint(
      'handleMapStateChange — userPosition: ${state.userPosition}, hasCenteredCameraOnce: ${state.hasCenteredCameraOnce}, originAddress: ${state.originAddress}, driverMarkersCount: ${state.driverMarkers.length}',
    );
    if (state.clientRequestSended ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request sent')));
      debugPrint('Navigating to ${ClientDriverOffersPage.routeName}');
      if (state.createdClientRequest?.id != null) {
        await Navigator.pushNamed(
          context,
          ClientDriverOffersPage.routeName,
          arguments: state.createdClientRequest!.id,
        );
      } else {
        CoreUtils.showSnackBar(context, 'Couldnt create request');
      }
    }

    onUpdateSelectedField(state.selectedField);
    print(
      ' state.userPosition != null && !state.hasCenteredCameraOnce: ${state.userPosition != null && !state.hasCenteredCameraOnce}',
    );
    // Updates the camera if theres is a userPosition
    if (state.userPosition != null && !state.hasCenteredCameraOnce) {
      final latLng = LatLng(
        state.userPosition!.latitude,
        state.userPosition!.longitude,
      );

      // prevents the camera to do too many updates
      if (!(latLng.latitude.abs() < 0.000001 &&
          latLng.longitude.abs() < 0.000001)) {
        try {
          print(
            '------------------------------------MOVING CAMERA TO USER POSITION FROM LISTENER latLng $latLng',
          );
          await moveCameraTo(
            controller: mapController,
            target: latLng,
            zoom: 16,
          );
          if (!context.mounted) return;

          context.read<ClientMapSeekerBloc>().add(ClientMapCameraCentered());
        } catch (_) {}
      }

      onUpdateOriginLatLng(latLng);

      //Uses the adrres if we have one else get it once
      if (state.originAddress != null && state.originAddress!.isNotEmpty) {
        pickUpController
          ..text = state.originAddress!
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: state.originAddress!.length),
          );
      } else {
        try {
          final addr = await getAddressFromLatLng(latLng);
          if (addr.isNotEmpty) {
            pickUpController
              ..text = addr
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: addr.length),
              );
          }
        } catch (_) {}
      }
    }

    //Updates the origin and destination fields
    if (state.originAddress != null && state.originAddress!.isNotEmpty) {
      pickUpController
        ..text = state.originAddress!
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: state.originAddress!.length),
        );
      onUpdateOriginLatLng(state.origin);
    }

    if (state.destinationAddress != null &&
        state.destinationAddress!.isNotEmpty) {
      destinationController
        ..text = state.destinationAddress!
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: state.destinationAddress!.length),
        );
      onUpdateDestinationLatLng(state.destination);
    }

    //  IF we have polylines drawn -> animate the route with padding
    if (state.polylines.isNotEmpty) {
      try {
        final controller = await mapController.future;

        //Extracts the points from the first polyline
        //(or generates a complete list if you have multiple)
        final firstPolyline = state.polylines.values.first;
        final latLngPoints = firstPolyline.points;
        if (!context.mounted) return;

        FocusScope.of(context).unfocus();

        await animateRouteWithPadding(
          controller: controller,
          context: context,
          points: latLngPoints,
          enablePadding: () => onSetShowMapPadding(true),
        );
      } catch (e) {
        debugPrint('Error animating route: $e');
        onSetShowMapPadding(false);
      }
    } else {
      onSetShowMapPadding(false);
    }

    return;
  }

  if (state is ClientMapSeekerError) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(state.message)));
    return;
  }
  //Fallback: if something different is received, reset padding
  onSetShowMapPadding(false);
}
