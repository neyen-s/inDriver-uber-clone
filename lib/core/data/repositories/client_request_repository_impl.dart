import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/data/datasources/dto/time_and_distance_values_dto.dart';
import 'package:indriver_uber_clone/core/data/datasources/source/client_request_datasource.dart';
import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class ClientRequestRepositoryImpl implements ClientRequestRepository {
  const ClientRequestRepositoryImpl({required this.timeAndDistanceValuesDto});

  final ClientRequestDataSource timeAndDistanceValuesDto;

  @override
  ResultFuture<TimeAndDistanceValuesDto> getTimeAndDistanceClientRequests(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) async {
    try {
      final timeAndDistanceValues = await timeAndDistanceValuesDto
          .getTimeAndDistanceClientRequest(
            originLat: originLat,
            originLng: originLng,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
          );
      return Right(timeAndDistanceValues);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.toString(), statusCode: e.statusCode),
      );
    }
  }
}
