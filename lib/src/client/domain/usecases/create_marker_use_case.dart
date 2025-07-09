import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/client/domain/repository/geolocator_repository.dart';

class CreateMarkerUseCase {
  CreateMarkerUseCase(this.geolocatorRepository);
  final GeolocatorRepository geolocatorRepository;
  ResultFuture<BitmapDescriptor> call(String path) =>
      geolocatorRepository.createMarkerFromAsset(path);
}
