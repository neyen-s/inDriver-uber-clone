import 'package:flutter/cupertino.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_position_dto.dart';

abstract class DriverPositionDatasource {
  Future<bool> create({required DriverPositionDTO driverPosition});

  Future<String> delete({required String idDriver});

  Future<DriverPositionDTO> getDriverPosition({required String idDriver});
}

class DriverPositionDatasourceImpl implements DriverPositionDatasource {
  DriverPositionDatasourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<bool> create({required DriverPositionDTO driverPosition}) async {
    await apiClient.post(
      path: '/drivers-position',
      body: driverPosition.toJson(),
    );

    return true;
  }

  @override
  Future<String> delete({required String idDriver}) async {
    print('**DELETE: $idDriver');
    final data = await apiClient.delete(path: '/drivers-position/$idDriver');
    return data['message'].toString();
  }

  @override
  Future<DriverPositionDTO> getDriverPosition({
    required String idDriver,
  }) async {
    debugPrint('**GET driver position of: $idDriver');
    final response = await apiClient.get(path: '/drivers-position/$idDriver');

    debugPrint('**RESPONSE: $response');

    return DriverPositionDTO.fromJson(response);
  }
}
