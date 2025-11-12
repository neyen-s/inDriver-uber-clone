import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_car_info_repository.dart';

class GetDriverCarInfoUseCase extends UsecaseWithParams<void, int> {
  const GetDriverCarInfoUseCase(this.repository);
  final DriverCarInfoRepository repository;

  @override
  ResultFuture<DriverCarInfoEntity> call(int driverId) async {
    return repository.getDriverCarInfo(driverId);
  }
}
