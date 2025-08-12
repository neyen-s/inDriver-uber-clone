import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

abstract class GeolocatorRepository {
  ResultFuture<Position> findPosition();

  ResultFuture<BitmapDescriptor> createMarkerFromAsset(String path);
  ResultFuture<Marker> getMarker(
    String id,
    String title,
    String content,
    LatLng position,
    BitmapDescriptor icon,
  );

  Stream<Position> getPositionStream();
}
