import 'package:geolocator/geolocator.dart';
import 'package:indriver_uber_clone/core/domain/repositories/geolocator_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class FindPositionUseCase {
  FindPositionUseCase(this.geolocatorRepository);

  GeolocatorRepository geolocatorRepository;

  ResultFuture<Position> call() => geolocatorRepository.findPosition();
}
