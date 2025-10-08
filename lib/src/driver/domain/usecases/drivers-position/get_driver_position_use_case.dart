import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_position_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_position_repository.dart';

class GetDriverPositionUseCase {
  const GetDriverPositionUseCase(this.repository);

  final DriverPositionRepository repository;

  ResultFuture<DriverPositionEntity> call({required int idDriver}) =>
      repository.getDriverPosition(idDriver: idDriver);
}
