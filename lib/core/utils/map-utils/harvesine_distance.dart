import 'dart:math';

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371.0; // km
  final dLat = deg2rad(lat2 - lat1);
  final dLon = deg2rad(lon2 - lon1);
  final a =
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double deg2rad(double deg) => deg * (3.141592653589793 / 180.0);

//Estimates minutes; average speed assumed 30 km/h
int estimateMinutesFromKm(double km, {double avgKmH = 30.0}) {
  if (km <= 0) return 0;
  final hours = km / avgKmH;
  return (hours * 60).round();
}
