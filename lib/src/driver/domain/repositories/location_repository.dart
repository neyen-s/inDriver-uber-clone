import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationRepository {
  Stream<LatLng> getDriverPositionStream();
}
