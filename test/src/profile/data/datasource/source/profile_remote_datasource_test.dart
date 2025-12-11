import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/profile/data/datasource/source/profile_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late ProfileRemoteDataSource datasource;

  const tUserDto = UserDTO.empty();

  setUpAll(() {
    registerFallbackValue(tUserDto);
  });

  setUp(() {
    mockApiClient = MockApiClient();
    datasource = ProfileRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('updateProfile', () {
    test(
      'should complete successfully when no [Exception] is thrown',
      () async {
        when(
          () => mockApiClient.put(
            path: any(named: 'path'),
            headers: any(named: 'headers'),
            fields: any(named: 'fields'),
            file: any(named: 'file'),
          ),
        ).thenAnswer((_) async => tUserDto.toJson());

        final response = await datasource.updateProfile(
          tUserDto,
          'token',
          null,
        );

        expect(response, isA<UserDTO>());
        expect(response.id, tUserDto.id);
        expect(response.name, tUserDto.name);
        expect(response.lastname, tUserDto.lastname);
        expect(response.phone, tUserDto.phone);

        verify(
          () => mockApiClient.put(
            path: '/users/upload/${tUserDto.id}',
            headers: {'Authorization': 'Bearer token'},
            fields: {
              'name': tUserDto.name,
              'lastname': tUserDto.lastname,
              'phone': tUserDto.phone,
            },
          ),
        ).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );

    test(
      'should throw [Exception] when apiClient.put throws [Exception]',
      () async {
        when(
          () => mockApiClient.put(
            path: any(named: 'path'),
            headers: any(named: 'headers'),
            fields: any(named: 'fields'),
            file: any(named: 'file'),
          ),
        ).thenThrow(Exception());

        expect(
          datasource.updateProfile(tUserDto, 'token', null),
          throwsException,
        );
        verify(
          () => mockApiClient.put(
            path: '/users/upload/${tUserDto.id}',
            headers: {'Authorization': 'Bearer token'},
            fields: {
              'name': tUserDto.name,
              'lastname': tUserDto.lastname,
              'phone': tUserDto.phone,
            },
          ),
        ).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });
}
