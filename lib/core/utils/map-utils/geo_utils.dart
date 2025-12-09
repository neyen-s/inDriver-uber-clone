import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371.0; // km
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a =
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_deg2rad(lat1)) *
          cos(_deg2rad(lat2)) *
          (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _deg2rad(double deg) => deg * (pi / 180.0);

double haversineDistanceMeters(LatLng a, LatLng b) {
  return haversineKm(a.latitude, a.longitude, b.latitude, b.longitude) * 1000.0;
}

/// Wrapper using Geolocator; simple and reliable.
/// You can switch implementation to haversine if you prefer.
double distanceBetweenMeters(LatLng a, LatLng b) {
  return Geolocator.distanceBetween(
    a.latitude,
    a.longitude,
    b.latitude,
    b.longitude,
  );
}

/// Generic approx equality using meters threshold.
/// By default uses Geolocator.distanceBetween for simplicity.
bool approxSameLatLng(LatLng a, LatLng b, {double metersThreshold = 5.0}) {
  //TODO CHECK the actual need of this function
  final d = distanceBetweenMeters(a, b);
  return d <= metersThreshold;
}
