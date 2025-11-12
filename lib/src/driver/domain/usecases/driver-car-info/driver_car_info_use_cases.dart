import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/create_driver_car_info_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/get_driver_car_info_use_case.dart';

class DriverCarInfoUseCases {
  const DriverCarInfoUseCases({
    required this.createDriverCarInfoUseCase,
    required this.getDriverCarInfoUseCase,
  });
  final CreateDriverCarInfoUseCase createDriverCarInfoUseCase;
  final GetDriverCarInfoUseCase getDriverCarInfoUseCase;
}
