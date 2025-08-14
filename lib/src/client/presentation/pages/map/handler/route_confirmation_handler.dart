import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

Future<void> handleRouteConfirmation({
  required BuildContext context,
  required String originText,
  required String destinationText,
  required LatLng? originLatLng,
  required LatLng? destinationLatLng,
  required LatLng? fallbackOrigin,
  required LatLng? fallbackDestination,
  required VoidCallback onSuccess,
}) async {
  FocusScope.of(context).unfocus();
  await Future<void>.delayed(const Duration(milliseconds: 300));

  final origin = originText.trim();
  final destination = destinationText.trim();

  final currentOrigin = originLatLng ?? fallbackOrigin;
  final currentDestination = destinationLatLng ?? fallbackDestination;
  print('**** handleRouteConfirmation all must have a value ****');
  print(
    'Current Origin: $currentOrigin, Current Destination: $currentDestination',
  );
  print('Origin: $origin, Destination: $destination');
  if (origin.isNotEmpty &&
      destination.isNotEmpty &&
      currentOrigin != null &&
      currentDestination != null) {
    context.read<ClientMapSeekerBloc>().add(
      ConfirmTripDataEntered(
        origin: origin,
        destination: destination,
        originLatLng: currentOrigin,
        destinationLatLng: currentDestination,
      ),
    );
    onSuccess();
  }
}
