import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';

abstract class DriverCarInfoRepository {
  ResultFuture<bool> createDriverCarInfo(DriverCarInfoEntity driverCarInfo);

  ResultFuture<DriverCarInfoEntity> getDriverCarInfo(int driverId);
}
