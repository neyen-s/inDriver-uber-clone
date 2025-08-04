import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerIconService {
  Future<BitmapDescriptor> getOriginIcon() async {
    return BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/img/pin_white.png',
    );
  }

  Future<BitmapDescriptor> getDestinationIcon() async {
    return BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/img/flag.png',
    );
  }
}
