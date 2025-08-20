import 'package:geolocator/geolocator.dart';
import 'package:indriver_uber_clone/core/domain/repositories/geolocator_repository.dart';

class GetPositionStreamUseCase {
  GetPositionStreamUseCase(this.repository);
  final GeolocatorRepository repository;

  Stream<Position> call() => repository.getPositionStream();
}
