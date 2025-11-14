import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/get_driver_car_info_use_case.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_driver_car_info_repository.mock.dart';

void main() {
  late MockDriverCarInfoRepository mockRepo;
  late GetDriverCarInfoUseCase usecase;

  setUpAll(() {
    registerFallbackValue(
      DriverCarInfoEntity(idDriver: 1, brand: 'X', color: 'Y', plate: 'Z'),
    );
  });

  setUp(() {
    mockRepo = MockDriverCarInfoRepository();
    usecase = GetDriverCarInfoUseCase(mockRepo);
  });

  test(
    'Should foward call to repository and return Right(DriverCarInfoEntity) ',
    () async {
      final entity = DriverCarInfoEntity(
        idDriver: 1,
        brand: 'Mazda',
        color: 'Blue',
        plate: '1234 AAA',
      );

      when(
        () => mockRepo.getDriverCarInfo(any()),
      ).thenAnswer((_) async => Right(entity));

      final result = await usecase.call(1);

      result.fold(
        (l) => fail('Expected Right(DriverCarInfoEntity) but got Left($l)'),
        (r) => expect(r, entity),
      );

      verify(() => mockRepo.getDriverCarInfo(1)).called(1);
      verifyNoMoreInteractions(mockRepo);
    },
  );
  test(
    'Should foward call to repository and return Left(DriverCarInfoEntity) ',
    () async {
      const failure = ServerFailure(message: 'server error', statusCode: 500);

      when(
        () => mockRepo.getDriverCarInfo(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase.call(1);

      result.fold(
        (l) => expect(l, failure),
        (r) => fail('Expected Right(DriverCarInfoEntity) but got Left($r)'),
      );

      verify(() => mockRepo.getDriverCarInfo(1)).called(1);
      verifyNoMoreInteractions(mockRepo);
    },
  );
}
