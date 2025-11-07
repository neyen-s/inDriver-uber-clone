import 'package:flutter/cupertino.dart';
import 'package:indriver_uber_clone/core/data/datasources/dto/time_and_distance_values_dto.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/client/data/datasources/dto/client_request_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/client_request_response_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_trip_request_dto.dart';

sealed class ClientRequestDataSource {
  const ClientRequestDataSource();

  Future<TimeAndDistanceValuesDto> getTimeAndDistanceClientRequest({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  });

  Future<Map<String, dynamic>> createClientRequest({
    required ClientRequestDTO clientRequestDTO,
  });

  Future<List<ClientRequestResponseDto>> getNearbyTripRequest(
    double driverLat,
    double driverLng,
  );

  Future<List<DriverTripRequestDTO>> getDriverTripOffersByClientRequest(
    int idClientRequest,
  );
  Future<bool> updateDriverAssigned(
    int idClientRequest,
    int idDriver,
    double fareAssigned,
  );
}

class ClientRequestDataSourceImpl implements ClientRequestDataSource {
  const ClientRequestDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<TimeAndDistanceValuesDto> getTimeAndDistanceClientRequest({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final response = await apiClient.get(
      path:
          '/client-requests/$originLat/$originLng/$destinationLat/$destinationLng',
      timeout: const Duration(seconds: 7),
    );
    debugPrint('**getTimeAndDistanceClientRequest RESPONSE: $response');

    final dto = TimeAndDistanceValuesDto.fromJson(response);

    debugPrint('**getTimeAndDistanceClientRequest DTO: $dto');

    return dto;
  }

  @override
  Future<Map<String, dynamic>> createClientRequest({
    required ClientRequestDTO clientRequestDTO,
  }) async {
    debugPrint('**createClientRequest DTO: $clientRequestDTO');
    final response = await apiClient.post(
      path: '/client-requests',
      body: clientRequestDTO.toJson(),
    );

    debugPrint('**createClientRequest RESPONSE: $response');
    return response;
  }

  @override
  Future<List<ClientRequestResponseDto>> getNearbyTripRequest(
    double driverLat,
    double driverLng,
  ) async {
    debugPrint('**getNearbyTripRequest');
    final response = await apiClient.get(
      path: '/client-requests/$driverLat/$driverLng',
    );
    final clientRequestResponseDtos = <ClientRequestResponseDto>[];

    debugPrint(
      '**getNearbyTripRequest DTO: ${clientRequestResponseDtos.length}',
    );
    debugPrint('--RESPONSE: ${response['data']}');

    response['data'].forEach((element) {
      clientRequestResponseDtos.add(
        ClientRequestResponseDto.fromJson(element as Map<String, dynamic>),
      );
    });

    debugPrint(
      '**getNearbyTripRequest DTO: ${clientRequestResponseDtos.length}',
    );

    return clientRequestResponseDtos;
  }

  @override
  Future<List<DriverTripRequestDTO>> getDriverTripOffersByClientRequest(
    int idDriver,
  ) async {
    debugPrint('**getDriverTripOffersByClientRequest');
    final response = await apiClient.get(
      path: '/driver-trip-offers/findByClientRequest/$idDriver',
    );

    debugPrint('**getDriverTripOffersByClientRequest RESPONSE: $response');

    final driverTripRequestsResponseDtos = <DriverTripRequestDTO>[];

    response['data'].forEach((element) {
      driverTripRequestsResponseDtos.add(
        DriverTripRequestDTO.fromJson(element as Map<String, dynamic>),
      );
    });
    debugPrint(
      '**getDriverTripOffersByClient LIST: $driverTripRequestsResponseDtos',
    );

    return driverTripRequestsResponseDtos;
  }

  @override
  Future<bool> updateDriverAssigned(
    Object idClientRequest,
    int idDriver,
    double fareAssigned,
  ) async {
    debugPrint('**updateDriverAssigned');
    final response = await apiClient.put(
      path: '/client-requests/updateDriverAssigned',
      body: {
        'id': idClientRequest,
        'id_driver_assigned': idDriver,
        'fare_assigned': fareAssigned,
      },
    );

    debugPrint('**updateDriverAssigned RESPONSE: $response');
    if (response['success'] == true) {
      return true;
    }
    if (response.containsKey('message')) {
      throw Exception(response['message']?.toString() ?? 'Server error');
    }

    return false;
  }
}
