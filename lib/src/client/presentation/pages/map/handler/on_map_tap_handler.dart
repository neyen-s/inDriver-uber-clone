import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

Future<void> Function(LatLng) onMapTapHandler({
  required BuildContext context,
  required Completer<GoogleMapController> mapController,
  required FocusNode originFocusNode,
  required FocusNode destinationFocusNode,
  required LatLng? originLat,
  required LatLng? destinationLat,
  required void Function(LatLng) onSetOrigin,
  required void Function(LatLng) onSetDestination,
}) {
  return (LatLng tapped) async {
    SelectedField targetField;
    final bloc = context.read<ClientMapSeekerBloc>();

    if (originFocusNode.hasFocus) {
      targetField = SelectedField.origin;
    } else if (destinationFocusNode.hasFocus) {
      targetField = SelectedField.destination;
    } else {
      targetField = (originLat == null)
          ? SelectedField.origin
          : SelectedField.destination;
      bloc.add(ChangeSelectedFieldRequested(targetField));
    }

    if (targetField == SelectedField.origin) {
      onSetOrigin(tapped);
    } else {
      onSetDestination(tapped);
    }

    await mapController.future;
    await moveCameraTo(controller: mapController, target: tapped, zoom: 16);

    bloc
      ..add(GetAddressFromLatLng(tapped, selectedField: targetField))
      ..add(ChangeSelectedFieldRequested(targetField));
  };
}
