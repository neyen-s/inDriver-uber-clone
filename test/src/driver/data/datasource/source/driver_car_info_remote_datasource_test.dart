import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_car_info_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/source/driver_car_info_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late DriverCarInfoRemoteDataSource datasource;
  setUpAll(() {
    registerFallbackValue(
      DriverCarInfoDTO(idDriver: 1, brand: 'X', color: 'Y', plate: 'Z'),
    );
  });

  setUp(() {
    mockApiClient = MockApiClient();
    datasource = DriverCarInfoRemoteDatasourceImpl(apiClient: mockApiClient);
  });

  final dto = DriverCarInfoDTO(idDriver: 1, brand: 'X', color: 'Y', plate: 'Z');

  group('createDriverCarInfo', () {
    test('should complete succesfully when no [Exception] is thrown', () async {
      when(
        () => mockApiClient.post(
          path: any(named: 'path'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => dto.toJson());

      final response = await datasource.createDriverCarInfo(dto);
      expect(response, isA<DriverCarInfoDTO>());
      expect(response.idDriver, dto.idDriver);
      expect(response.brand, dto.brand);
      expect(response.color, dto.color);
      expect(response.plate, dto.plate);

      verify(
        () => mockApiClient.post(path: '/driver-car-info', body: dto.toJson()),
      ).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test(
      'should throw [Exception] when apiClient.post throws [Exception]',
      () async {
        when(
          () => mockApiClient.post(
            path: any(named: 'path'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('network error'));

        final call = datasource.createDriverCarInfo(dto);

        expect(call, throwsA(isA<Exception>()));

        verify(
          () =>
              mockApiClient.post(path: '/driver-car-info', body: dto.toJson()),
        ).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });
  group('getDriverCarInfo', () {
    test('should complete succesfully when no [Exception] is thrown', () async {
      when(
        () => mockApiClient.get(path: any(named: 'path')),
      ).thenAnswer((_) async => dto.toJson());

      final response = await datasource.getDriverCarInfo(1);

      expect(response, isA<DriverCarInfoDTO>());
      expect(response.idDriver, dto.idDriver);
      expect(response.brand, dto.brand);
      expect(response.color, dto.color);
      expect(response.plate, dto.plate);

      verify(() => mockApiClient.get(path: '/driver-car-info/1')).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test(
      'should throw [Exception] when apiClient.post throws [Exception]',
      () async {
        when(
          () => mockApiClient.get(path: any(named: 'path')),
        ).thenThrow(Exception('network error'));

        final call = datasource.getDriverCarInfo(1);

        expect(call, throwsA(isA<Exception>()));

        verify(() => mockApiClient.get(path: '/driver-car-info/1')).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });
}
