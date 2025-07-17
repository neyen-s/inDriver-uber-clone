import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<String> getAddressFromLatLng(LatLng latLng) async {
  final placemarks = await placemarkFromCoordinates(
    latLng.latitude,
    latLng.longitude,
  );

  if (placemarks.isEmpty) return 'Unknown location';

  final place = placemarks.first;
  return '${place.street}, ${place.subThoroughfare} ${place.locality} ';
}
