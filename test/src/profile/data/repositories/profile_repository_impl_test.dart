import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/mappers/user_mapper.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/profile/data/datasource/source/profile_remote_datasource.dart';
import 'package:indriver_uber_clone/src/profile/data/repositories/profile_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements ProfileRemoteDataSource {}

class FakeFile extends Fake implements File {}

void main() {
  late MockRemoteDataSource mockRemoteDataSource;
  late ProfileRepositoryImpl profileRepositoryImpl;

  const tUserDto = UserDTO.empty();
  const tUserEntity = UserEntity.empty();
  setUpAll(() {
    registerFallbackValue(tUserDto);
    registerFallbackValue(tUserEntity);
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    profileRepositoryImpl = ProfileRepositoryImpl(
      profileRemoteDataSource: mockRemoteDataSource,
    );
  });

  group('Update user info', () {
    test('should return UserDTO when update is successful', () async {
      when(
        () => mockRemoteDataSource.updateProfile(any(), any(), any()),
      ).thenAnswer((_) async => tUserDto);

      final result = await profileRepositoryImpl.updateUser(
        tUserEntity.toDto(),
        'token',
        null,
      );

      expect(result.isRight(), isTrue);

      result.fold(
        (l) => fail('expected Right but got Left($l)'),
        (r) => expect(r, tUserDto),
      );

      verify(
        () => mockRemoteDataSource.updateProfile(any(), any(), any()),
      ).called(1);
    });

    test(
      'should return Failure when  when datasource throws ServerException',
      () async {
        when(
          () => mockRemoteDataSource.updateProfile(any(), any(), any()),
        ).thenThrow(const ServerException(message: 'server', statusCode: 500));

        final result = await profileRepositoryImpl.updateUser(
          tUserDto.toEntity(),
          'token',
          null,
        );

        expect(result.isLeft(), isTrue);

        result.fold(
          (l) => expect(
            l.runtimeType.toString().toLowerCase(),
            contains('failure'),
          ),
          (r) => fail('expected Left but got Right($r)'),
        );

        verify(
          () => mockRemoteDataSource.updateProfile(any(), any(), any()),
        ).called(1);
      },
    );

    test(
      'should return Left(Failure) when datasource throws generic exception',
      () async {
        when(
          () => mockRemoteDataSource.updateProfile(any(), any(), any()),
        ).thenThrow(Exception('network error'));

        // act
        final result = await profileRepositoryImpl.updateUser(
          tUserEntity,
          'token',
          null,
        );

        // assert
        expect(result.isLeft(), isTrue);
        result.fold((l) {
          expect(l.runtimeType.toString().toLowerCase(), contains('failure'));
        }, (r) => fail('expected Left but got Right($r)'));

        verify(
          () => mockRemoteDataSource.updateProfile(any(), any(), any()),
        ).called(1);
      },
    );
  });
}
