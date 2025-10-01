import 'package:indriver_uber_clone/core/data/datasources/dto/time_and_distance_values_dto.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/client/data/datasources/dto/client_request_dto.dart';

sealed class ClientRequestDataSource {
  const ClientRequestDataSource();

  Future<TimeAndDistanceValuesDto> getTimeAndDistanceClientRequest({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  });

  Future<bool> createClientRequest({
    required ClientRequestDTO clientRequestDTO,
  });
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
    );
    print('**getTimeAndDistanceClientRequest RESPONSE: $response');

    final dto = TimeAndDistanceValuesDto.fromJson(response);

    print('**getTimeAndDistanceClientRequest DTO: $dto');

    return dto;
  }

  @override
  Future<bool> createClientRequest({
    required ClientRequestDTO clientRequestDTO,
  }) async {
    print('**createClientRequest DTO: $clientRequestDTO');
    final response = await apiClient.post(
      path: '/client-requests',
      body: clientRequestDTO.toJson(),
    );

    print('**createClientRequest RESPONSE: $response');
    return true;
  }
}
