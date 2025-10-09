import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_trip_request_dto.dart';

abstract class DriverTripRequestDatasource {
  Future<void> createDriverTripRequests({
    required DriverTripRequestDTO driverTripRequest,
  });
  Future<List<DriverTripRequestDTO>> getDriverTripRequests(int idDriver);
}

class DriverTripRequestDatasourceImpl implements DriverTripRequestDatasource {
  const DriverTripRequestDatasourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<void> createDriverTripRequests({
    required DriverTripRequestDTO driverTripRequest,
  }) async {
    debugPrint('**DriverTripRequestDatasourceImpl -> createDriverTripRequests');

    final response = await apiClient.post(
      path: '/driver-trip-offers',
      body: driverTripRequest.toJson(),
    );
    debugPrint('**createDriverTripRequests RESPONSE: $response');
    // return null;
  }

  @override
  Future<List<DriverTripRequestDTO>> getDriverTripRequests(int idDriver) async {
    debugPrint('**DriverTripRequestDatasourceImpl -> getDriverTripRequests');
    final response = await apiClient.get(path: '/driver-trip-offers/$idDriver');

    final driverTripRequests = <DriverTripRequestDTO>[];
    debugPrint('**getDriverTripRequests RESPONSE: $response');
    response['data'].forEach((DriverTripRequestDTO element) {
      driverTripRequests.add(
        DriverTripRequestDTO.fromJson(element as Map<String, dynamic>),
      );
    });
    debugPrint('**getDriverTripRequests  list: $driverTripRequests');

    return driverTripRequests;
  }
}
