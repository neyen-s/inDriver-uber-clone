import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  DirectionsService(this._apiKey);
  final String _apiKey;

  Future<List<LatLng>> getRoutePolyline({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error getting directions');
    }

    final data = json.decode(response.body);

    if ((data['routes'] as List).isEmpty) {
      throw Exception('No route found');
    }

    final points = PolylinePoints.decodePolyline(
      data['routes'][0]['overview_polyline']['points'] as String,
    );

    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }
}
