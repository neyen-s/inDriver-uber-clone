import 'package:flutter/cupertino.dart';
import 'package:indriver_uber_clone/core/data/datasources/dto/time_and_distance_values_dto.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
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

  Future<ClientRequestResponseDto> getClientRequestById(int idClientRequest);

  Future<bool> updateTripStatus(int idClientRequest, String status);
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
    try {
      final dto = TimeAndDistanceValuesDto.fromJson(response);

      debugPrint('**getTimeAndDistanceClientRequest DTO: $dto');

      return dto;
    } catch (e) {
      throw Exception('Error parsing TimeAndDistanceValuesDto: $e');
    }
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

    final rawList = response['data'] ?? response;
    if (rawList == null) {
      throw Exception('getNearbyTripRequest: response.data is null');
    }
    if (rawList is! List) {
      throw Exception(
        'getNearbyTripRequest: unexpected response format, expected List',
      );
    }
    final clientRequestResponseDtos = <ClientRequestResponseDto>[];
    for (var i = 0; i < rawList.length; i++) {
      final element = rawList[i];
      try {
        if (element is! Map<String, dynamic>) {
          debugPrint(
            'getNearbyTripRequest: skipping non-map element at index $i',
          );
          continue;
        }
        clientRequestResponseDtos.add(
          ClientRequestResponseDto.fromJson(element),
        );
      } catch (e, st) {
        debugPrint('getNearbyTripRequest: parse error at index $i -> $e\n$st');
        // continue trying other elements
      }
    }

    // if there were items in the raw response but none parsed -> treat as error
    if (rawList.isNotEmpty && clientRequestResponseDtos.isEmpty) {
      throw Exception('getNearbyTripRequest: all items failed to parse');
    }

    debugPrint(
      '**getNearbyTripRequest parsed: ${clientRequestResponseDtos.length}',
    );
    return clientRequestResponseDtos;
  }

  @override
  Future<List<DriverTripRequestDTO>> getDriverTripOffersByClientRequest(
    int idClientRequest,
  ) async {
    debugPrint('**getDriverTripOffersByClientRequest id: $idClientRequest');
    final response = await apiClient.get(
      path: '/driver-trip-offers/findByClientRequest/$idClientRequest',
    );

    final rawList = response['data'] ?? response;
    if (rawList == null) {
      throw Exception(
        'getDriverTripOffersByClientRequest: response.data is null',
      );
    }
    if (rawList is! List) {
      throw Exception(
        'getDriverTripOffersByClientRequest:'
        ' unexpected response format, expected List',
      );
    }

    final out = <DriverTripRequestDTO>[];
    for (var i = 0; i < rawList.length; i++) {
      final el = rawList[i];
      try {
        if (el is! Map<String, dynamic>) {
          debugPrint(
            'getDriverTripOffersByClientRequest:'
            ' skipping non-map element at index $i',
          );
          continue;
        }
        out.add(DriverTripRequestDTO.fromJson(el));
      } catch (e, st) {
        debugPrint(
          'getDriverTripOffersByClientRequest: '
          'parse error at index $i -> $e\n$st',
        );
      }
    }

    if (rawList.isNotEmpty && out.isEmpty) {
      throw Exception(
        'getDriverTripOffersByClientRequest: all items failed to parse',
      );
    }

    debugPrint('**getDriverTripOffersByClient LIST parsed: ${out.length}');
    return out;
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

  @override
  Future<ClientRequestResponseDto> getClientRequestById(
    int idClientRequest,
  ) async {
    debugPrint('**getClientRequestById');
    final response = await apiClient.get(
      path: '/client-requests/$idClientRequest',
    );
    debugPrint('**getClientRequestById RESPONSE: $response');
    try {
      final dto = ClientRequestResponseDto.fromJson(response);
      debugPrint('**getClientRequestById DTO: $dto');

      return dto;
    } catch (e) {
      throw Exception('Error parsing ClientRequestResponseDto: $e');
    }
  }

  @override
  Future<bool> updateTripStatus(int idClientRequest, String status) async {
    debugPrint('**updateTripStatus');
    final response = await apiClient.put(
      path: '/client-requests/update_status/',
      body: {'id_client_request': idClientRequest, 'status': status},
    );

    debugPrint('**updateTripStatus RESPONSE: $response');
    if (response['success'] == true) {
      return true;
    }
    if (response.containsKey('message')) {
      throw Exception(response['message']?.toString() ?? 'Server error');
    }

    return false;
  }
}
