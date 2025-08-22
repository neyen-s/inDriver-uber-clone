import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  // Si es el nuevo estado "rico"
  if (state is ClientMapSeekerSuccess) {
    final s = state;

    // Selected field
    onUpdateSelectedField(s.selectedField);

    // 1) Usuario: si hay userPosition, mueve la cámara y actualiza pickup si procede
    if (s.userPosition != null && !s.hasCenteredCameraOnce) {
      final latLng = LatLng(
        s.userPosition!.latitude,
        s.userPosition!.longitude,
      );

      // Evita hacer zoom continuo si ya estabas ahí; criterio simple:
      if (!(latLng.latitude.abs() < 0.000001 &&
          latLng.longitude.abs() < 0.000001)) {
        try {
          await moveCameraTo(
            controller: mapController,
            target: latLng,
            zoom: 16,
          );
          context.read<ClientMapSeekerBloc>().add(ClientMapCameraCentered());
        } catch (_) {
          // si falla mover la camara, no rompe todo
        }
      }

      onUpdateOriginLatLng(latLng);

      // Si ya tenemos address en el state úsalo; si no, obténlo una única vez.
      if (s.originAddress != null && s.originAddress!.isNotEmpty) {
        pickUpController
          ..text = s.originAddress!
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: s.originAddress!.length),
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

    // 2) Si hay una selectedLatLng (por ejemplo después de buscar una dirección), actualiza los campos correspondientes
    if (s.originAddress != null && s.originAddress!.isNotEmpty) {
      pickUpController
        ..text = s.originAddress!
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: s.originAddress!.length),
        );
      onUpdateOriginLatLng(s.origin);
    }

    if (s.destinationAddress != null && s.destinationAddress!.isNotEmpty) {
      destinationController
        ..text = s.destinationAddress!
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: s.destinationAddress!.length),
        );
      onUpdateDestinationLatLng(s.destination);
    }

    // 3) Si hay polylines (mapPolylines) dibujadas -> animar la ruta con padding
    //    Asumimos que mapPolylines contiene Polyline cuyo `.points` es List<LatLng>.
    if (s.polylines.isNotEmpty) {
      try {
        final controller = await mapController.future;

        // Extrae los puntos de la primera polyline (o genera la lista completa si tienes varias)
        final firstPolyline = s.polylines.values.first;
        final latLngPoints = firstPolyline
            .points; // asegúrate que `.points` devuelve List<LatLng>

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

  // Si es error, mostramos snackbar (estado antiguo ClientMapSeekerError aún soportado)
  if (state is ClientMapSeekerError) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(state.message)));
    return;
  }

  // Fallback: si por cualquier razón recibe algo distinto, resetea padding
  onSetShowMapPadding(false);
}
