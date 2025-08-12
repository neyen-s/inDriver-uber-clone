import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/domain/repositories/geolocator_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class CreateMarkerUseCase {
  CreateMarkerUseCase(this.geolocatorRepository);
  final GeolocatorRepository geolocatorRepository;
  ResultFuture<BitmapDescriptor> call(String path) =>
      geolocatorRepository.createMarkerFromAsset(path);
}
