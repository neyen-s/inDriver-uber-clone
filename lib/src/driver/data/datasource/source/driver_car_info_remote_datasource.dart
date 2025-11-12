import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_car_info_dto.dart';

abstract class DriverCarInfoRemoteDataSource {
  Future<DriverCarInfoDTO> createDriverCarInfo(
    DriverCarInfoDTO driverCarInfoDTO,
  );

  Future<DriverCarInfoDTO> getDriverCarInfo(int driverId);
}

class DriverCarInfoRemoteDatasourceImpl
    implements DriverCarInfoRemoteDataSource {
  const DriverCarInfoRemoteDatasourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<DriverCarInfoDTO> createDriverCarInfo(
    DriverCarInfoDTO driverCarInfoDTO,
  ) async {
    debugPrint('**DriverCarInfoCarInfoDatasourceImpl -> createDriverCarInfo');
    final response = await apiClient.post(
      path: '/driver-car-info',
      body: driverCarInfoDTO.toJson(),
    );
    debugPrint('**createDriverCarInfo RESPONSE: $response');

    return DriverCarInfoDTO.fromJson(response);
  }

  @override
  Future<DriverCarInfoDTO> getDriverCarInfo(int driverId) async {
    final response = await apiClient.get(path: '/driver-car-info/$driverId');

    return DriverCarInfoDTO.fromJson(response);
  }
}
