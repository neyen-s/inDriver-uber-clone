import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
  ResultFuture<int> createClientRequest(
    ClientRequestEntity clientRequestEntity,
  ) async {
    try {
      final clientRequestDto = ClientRequestDTO.fromEntity(clientRequestEntity);

      // Llamada al datasource que devuelve el decoded Map (tu cambio reciente)
      final response = await clientRequestDataSource.createClientRequest(
        clientRequestDTO: clientRequestDto,
      );

      // Debug útil
      debugPrint(
        'ClientRequestRepositoryImpl.createClientRequest RESPONSE: $response',
      );

      // Intentar extraer varios posibles caminos al id (robusto)
      final dynamic rawId =
          response['data']?['id'] ??
          response['id'] ??
          response['data']?['id_client_request'] ??
          response['id_client_request'];

      if (rawId == null) {
        return Left(
          mapExceptionToFailure(
            Exception('createClientRequest: no id in response'),
          ),
        );
      }

      final idInt = int.tryParse(rawId.toString());
      if (idInt == null) {
        return Left(
          mapExceptionToFailure(
            Exception('createClientRequest: invalid id format: $rawId'),
          ),
        );
      }

      return Right(idInt);
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
