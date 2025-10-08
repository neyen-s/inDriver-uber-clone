import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/create_driver_position_usecase.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/delete_driver_position_usecase.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/get_driver_position_use_case.dart';

class DriverPositionUsecases {
  DriverPositionUsecases({
    required this.createDriverPositionUsecase,
    required this.deleteDriverPositionUsecase,
    required this.getDriverPositionUseCase,
  });

  CreateDriverPositionUsecase createDriverPositionUsecase;
  DeleteDriverPositionUsecase deleteDriverPositionUsecase;
  GetDriverPositionUseCase getDriverPositionUseCase;
}
