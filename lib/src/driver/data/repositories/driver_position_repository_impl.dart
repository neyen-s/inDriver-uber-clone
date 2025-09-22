import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_position_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/source/driver_position_datasource.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_position_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_position_repository.dart';

class DriverPositionRepositoryImpl implements DriverPositionRepository {
  const DriverPositionRepositoryImpl({required this.driverPositionDatasource});

  final DriverPositionDatasource driverPositionDatasource;

  @override
  ResultFuture<bool> create({
    required DriverPositionEntity driverPosition,
  }) async {
    try {
      final dto = DriverPositionDTO.fromEntity(driverPosition);

      await driverPositionDatasource.create(driverPosition: dto);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: e));
    }
  }

  @override
  ResultFuture<bool> delete({required int idDriver}) async {
    try {
      await driverPositionDatasource.delete(idDriver: idDriver.toString());
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: e));
    }
  }
}
