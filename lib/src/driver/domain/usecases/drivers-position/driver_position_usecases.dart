import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/create_driver_position_usecase.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/delete_driver_position_usecase.dart';

class DriverPositionUsecases {
  DriverPositionUsecases({
    required this.createDriverPositionUsecase,
    required this.deleteDriverPositionUsecase,
  });

  CreateDriverPositionUsecase createDriverPositionUsecase;
  DeleteDriverPositionUsecase deleteDriverPositionUsecase;
}
