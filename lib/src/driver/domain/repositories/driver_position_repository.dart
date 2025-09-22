import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_position_entity.dart';

abstract class DriverPositionRepository {
  const DriverPositionRepository();

  ResultFuture<bool> create({required DriverPositionEntity driverPosition});

  ResultFuture<bool> delete({required int idDriver});
}
