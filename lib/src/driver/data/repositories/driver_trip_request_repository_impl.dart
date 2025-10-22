import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/errors/error_mapper.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_trip_request_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/source/driver_trip_request_data_source.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_trip_request_repository.dart';

class DriverTripRequestRepositoryImpl implements DriverTripRequestRepository {
  const DriverTripRequestRepositoryImpl({
    required this.driverTripRequestDatasource,
  });

  final DriverTripRequestDatasource driverTripRequestDatasource;

  @override
  ResultFuture<void> createDriverTripRequests(
    DriverTripRequestEntity driverTripRequest,
  ) async {
    try {
      print('** DriverTripRequestRepositoryImpl -> createDriverTripRequests');
      final dto = DriverTripRequestDTO.fromEntity(driverTripRequest);
      await driverTripRequestDatasource.createDriverTripRequests(
        driverTripRequest: dto,
      );
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<DriverTripRequestEntity>> getDriverTripRequests(
    int idDriver,
  ) async {
    try {
      print('** DriverTripRequestRepositoryImpl -> getDriverTripRequests');
      final result = await driverTripRequestDatasource.getDriverTripRequests(
        idDriver,
      );
      return Right(result);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
