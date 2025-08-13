import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

double distanceBetweenMeters(LatLng a, LatLng b) {
  const earthRadius = 6371000.0;
  final lat1 = a.latitude * (3.141592653589793 / 180);
  final lat2 = b.latitude * (3.141592653589793 / 180);
  final dLat = lat2 - lat1;
  final dLon = (b.longitude - a.longitude) * (3.141592653589793 / 180);
  final sinDLat = sin(dLat / 2);
  final sinDLon = sin(dLon / 2);
  final hav = sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLon * sinDLon;
  final c = 2 * atan2(sqrt(hav), sqrt(1 - hav));
  return earthRadius * c;
}
