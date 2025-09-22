import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_position_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_position_repository.dart';

class CreateDriverPositionUsecase {
  CreateDriverPositionUsecase(this.driverPositionRepository);

  DriverPositionRepository driverPositionRepository;

  ResultFuture<bool> call({required DriverPositionEntity driverPosition}) {
    return driverPositionRepository.create(driverPosition: driverPosition);
  }
}
