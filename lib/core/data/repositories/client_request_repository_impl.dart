import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/data/datasources/dto/time_and_distance_values_dto.dart';
import 'package:indriver_uber_clone/core/data/datasources/source/client_request_datasource.dart';
import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/errors/error_mapper.dart';

import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/client/data/datasources/dto/client_request_dto.dart';
import 'package:indriver_uber_clone/src/client/domain/entities/client_request_entity.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/client_request_response_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_trip_request_dto.dart';

class ClientRequestRepositoryImpl implements ClientRequestRepository {
  const ClientRequestRepositoryImpl({required this.clientRequestDataSource});

  final ClientRequestDataSource clientRequestDataSource;

  @override
  ResultFuture<TimeAndDistanceValuesDto> getTimeAndDistanceClientRequests(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) async {
    try {
      final timeAndDistanceValues = await clientRequestDataSource
          .getTimeAndDistanceClientRequest(
            originLat: originLat,
            originLng: originLng,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
          );
      return Right(timeAndDistanceValues);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<bool> createClientRequest(
    ClientRequestEntity clientRequestEntity,
  ) async {
    try {
      final clientRequestDto = ClientRequestDTO.fromEntity(clientRequestEntity);
      await clientRequestDataSource.createClientRequest(
        clientRequestDTO: clientRequestDto,
      );
      return const Right(true);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<ClientRequestResponseDto>> getNearbyTripRequest(
    double driverLat,
    double driverLng,
  ) async {
    try {
      final clientRequestResponse = await clientRequestDataSource
          .getNearbyTripRequest(driverLat, driverLng);

      return Right(clientRequestResponse);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<DriverTripRequestDTO>> getDriverTripOffersByClientRequest(
    int idClientRequest,
  ) async {
    try {
      final driverTripOffers = await clientRequestDataSource
          .getDriverTripOffersByClientRequest(idClientRequest);

      return Right(driverTripOffers);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
