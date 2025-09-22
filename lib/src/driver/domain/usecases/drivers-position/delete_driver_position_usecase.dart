import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_position_repository.dart';

class DeleteDriverPositionUsecase {
  DeleteDriverPositionUsecase(this.driverPositionRepository);

  DriverPositionRepository driverPositionRepository;

  ResultFuture<bool> call({required int idDriver}) {
    return driverPositionRepository.delete(idDriver: idDriver);
  }
}
