import 'package:geolocator/geolocator.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/client/domain/repository/geolocator_repository.dart';

class FindPositionUseCase {
  FindPositionUseCase(this.geolocatorRepository);

  GeolocatorRepository geolocatorRepository;

  ResultFuture<Position> call() => geolocatorRepository.findPosition();
}
