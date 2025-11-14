import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/create_driver_car_info_use_case.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_driver_car_info_repository.mock.dart';

void main() {
  late MockDriverCarInfoRepository mockRepo;
  late CreateDriverCarInfoUseCase usecase;

  setUpAll(() {
    registerFallbackValue(
      DriverCarInfoEntity(idDriver: 1, brand: 'X', color: 'Y', plate: 'Z'),
    );
  });

  setUp(() {
    mockRepo = MockDriverCarInfoRepository();
    usecase = CreateDriverCarInfoUseCase(mockRepo);
  });

  test(
    'should forward call to repository and return Right(true) on success',
    () async {
      final entity = DriverCarInfoEntity(
        idDriver: 1,
        brand: 'Mazda',
        color: 'Blue',
        plate: '1234 AAA',
      );

      when(
        () => mockRepo.createDriverCarInfo(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.call(
        CreateDriverCarInfoParams(driverCarInfoEntity: entity),
      );

      result.fold(
        (l) => fail('Expected Right(true) but got Left($l)'),
        (r) => expect(r, isTrue),
      );

      verify(() => mockRepo.createDriverCarInfo(entity)).called(1);
      verifyNoMoreInteractions(mockRepo);
    },
  );

  test('Returns Left when repository fails', () async {
    final entity = DriverCarInfoEntity(
      idDriver: 1,
      brand: 'Mazda',
      color: 'Blue',
      plate: '1234 AAA',
    );
    const failure = ServerFailure(message: 'server error', statusCode: 500);

    when(
      () => mockRepo.createDriverCarInfo(any()),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(
      CreateDriverCarInfoParams(driverCarInfoEntity: entity),
    );

    result.fold(
      (l) => expect(l, failure),
      (r) => fail('expected Left but got Right'),
    );

    verify(() => mockRepo.createDriverCarInfo(entity)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
