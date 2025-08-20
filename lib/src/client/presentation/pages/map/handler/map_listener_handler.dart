import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/animate_route_with_padding.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/get_adress_from_latlng.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';
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
  if (state is SelectedFieldChanged) {
    onUpdateSelectedField(state.selectedField);
  }

  if (state is FindPositionSuccess) {
    final position = state.position;
    final latLng = LatLng(position.latitude, position.longitude);

    if (position.latitude.abs() < 0.001 && position.longitude.abs() < 0.001) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't find your location, try again."),
        ),
      );
      return;
    }

    await moveCameraTo(controller: mapController, target: latLng, zoom: 16);
    onUpdateOriginLatLng(latLng);

    final address = await getAddressFromLatLng(latLng);
    pickUpController.text = address;
  }

  if (state is AddressUpdatedSuccess) {
    if (state.field == SelectedField.origin) {
      pickUpController
        ..text = state.address
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: pickUpController.text.length),
        );
      onUpdateOriginLatLng(state.selectedLatLng);
    } else {
      destinationController
        ..text = state.address
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: destinationController.text.length),
        );
      onUpdateDestinationLatLng(state.selectedLatLng);
    }
  }

  if (state is TripReadyToDisplay) {
    final controller = await mapController.future;

    final latLngPoints = state.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();

    FocusScope.of(context).unfocus();

    await animateRouteWithPadding(
      controller: controller,
      context: context,
      points: latLngPoints,
      enablePadding: () => onSetShowMapPadding(true),
    );
  } else {
    onSetShowMapPadding(false);
  }

  if (state is ClientMapSeekerError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message)),
    ); //TODO FIND AN ALTERNATIVE TO SHOW SNACKBAR
  }
}
