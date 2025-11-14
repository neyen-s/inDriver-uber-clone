import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_car_info_dto.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/source/driver_car_info_remote_datasource.dart';
import 'package:indriver_uber_clone/src/driver/data/repositories/driver_car_info_repository_impl.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements DriverCarInfoRemoteDataSource {}

void main() {
  late MockRemote mockRemote;
  late DriverCarInfoRepositoryImpl repo;

  setUp(() {
    mockRemote = MockRemote();
    repo = DriverCarInfoRepositoryImpl(remoteDataSource: mockRemote);

    registerFallbackValue(
      DriverCarInfoDTO(idDriver: 1, brand: 'X', color: 'Y', plate: 'Z'),
    );
  });

  final dto = DriverCarInfoDTO(idDriver: 1, brand: 'X', color: 'Y', plate: 'Z');
  final entity = DriverCarInfoEntity(
    idDriver: 1,
    brand: 'X',
    color: 'Y',
    plate: 'Z',
  );

  group('CreateDriverCarInfo', () {
    test('should return true when creation is successful', () async {
      when(
        () => mockRemote.createDriverCarInfo(any()),
      ).thenAnswer((_) async => dto);

      final result = await repo.createDriverCarInfo(entity);

      expect(result.isRight(), isTrue);

      result.fold(
        (l) => fail('expected Right but got Left($l)'),
        (r) => expect(r, isTrue),
      );

      verify(() => mockRemote.createDriverCarInfo(any())).called(1);
    });

    test('returns Left(Failure) when remote throws Exception', () async {
      when(
        () => mockRemote.createDriverCarInfo(any()),
      ).thenThrow(Exception('network'));

      final result = await repo.createDriverCarInfo(entity);

      expect(result.isLeft(), isTrue);

      result.fold(
        (l) => expect(l, isA<Failure>()),
        (r) => fail('expected Left but got Right($r)'),
      );

      verify(() => mockRemote.createDriverCarInfo(any())).called(1);
    });

    test(
      'returns Left(SocketFailure) when remote throws SocketException',
      () async {
        when(
          () => mockRemote.createDriverCarInfo(any()),
        ).thenThrow(const SocketException('no internet'));

        final result = await repo.createDriverCarInfo(entity);

        expect(result.isLeft(), isTrue);

        result.fold(
          (l) => expect(l, isA<SocketFailure>()),
          (r) => fail('expected Left but got Right($r)'),
        );

        verify(() => mockRemote.createDriverCarInfo(any())).called(1);
      },
    );
  });

  group('GetDriverCarInfo', () {
    test(
      'should return DriverCarInfoDTO when creation is successful',
      () async {
        when(
          () => mockRemote.getDriverCarInfo(any()),
        ).thenAnswer((_) async => dto);

        final result = await repo.getDriverCarInfo(1);

        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('expected Right but got Left($l)'),
          (r) => expect(r, dto),
        );

        verify(() => mockRemote.getDriverCarInfo(any())).called(1);
      },
    );

    test('should return Failure when exception occurs', () async {
      when(
        () => mockRemote.getDriverCarInfo(any()),
      ).thenThrow(Exception('server'));

      final result = await repo.getDriverCarInfo(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<Failure>()),
        (r) => fail('expected Left but got Right($r)'),
      );

      verify(() => mockRemote.getDriverCarInfo(any())).called(1);
    });
  });
}
