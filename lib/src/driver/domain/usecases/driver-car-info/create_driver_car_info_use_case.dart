import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_car_info_repository.dart';

class CreateDriverCarInfoUseCase
    extends UsecaseWithParams<void, CreateDriverCarInfoParams> {
  CreateDriverCarInfoUseCase(this.repository);
  final DriverCarInfoRepository repository;

  @override
  ResultFuture<bool> call(CreateDriverCarInfoParams params) {
    return repository.createDriverCarInfo(params.driverCarInfoEntity);
  }
}

class CreateDriverCarInfoParams extends Equatable {
  const CreateDriverCarInfoParams({required this.driverCarInfoEntity});

  final DriverCarInfoEntity driverCarInfoEntity;

  @override
  List<Object?> get props => [driverCarInfoEntity];
}
