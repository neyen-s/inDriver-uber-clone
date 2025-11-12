import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/errors/error_mapper.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_car_info_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/source/driver_car_info_remote_datasource.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_car_info_repository.dart';

class DriverCarInfoRepositoryImpl implements DriverCarInfoRepository {
  DriverCarInfoRepositoryImpl({required this.remoteDataSource});

  final DriverCarInfoRemoteDataSource remoteDataSource;

  @override
  ResultFuture<bool> createDriverCarInfo(
    DriverCarInfoEntity driverCarInfo,
  ) async {
    try {
      final dtoToSend = DriverCarInfoDTO.fromEntity(driverCarInfo);

      final responseDto = await remoteDataSource.createDriverCarInfo(dtoToSend);

      if (responseDto.brand.isNotEmpty) {
        return const Right(true);
      } else {
        return Left(
          mapExceptionToFailure(Exception('Invalid response from server')),
        );
      }
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<DriverCarInfoDTO> getDriverCarInfo(int driverId) async {
    try {
      final result = await remoteDataSource.getDriverCarInfo(driverId);

      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
