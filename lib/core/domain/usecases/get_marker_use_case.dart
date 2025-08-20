import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/domain/repositories/geolocator_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class GetMarkerUseCase {
  GetMarkerUseCase(this.geolocatorRepository);
  final GeolocatorRepository geolocatorRepository;

  ResultFuture<Marker> call(
    String id,
    String title,
    String content,
    LatLng position,
    BitmapDescriptor icon,
  ) async {
    return geolocatorRepository.getMarker(id, title, content, position, icon);
  }
}
