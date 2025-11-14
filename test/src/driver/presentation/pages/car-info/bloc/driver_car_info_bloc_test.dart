import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/create_driver_car_info_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/driver_car_info_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/get_driver_car_info_use_case.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/driver_car_info_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthUseCases extends Mock implements AuthUseCases {}

class MockCreateDriverCarInfoUseCase extends Mock
    implements CreateDriverCarInfoUseCase {}

class MockGetDriverCarInfoUseCase extends Mock
    implements GetDriverCarInfoUseCase {}

void main() {
  late MockAuthUseCases mockAuth;
  late MockCreateDriverCarInfoUseCase mockCreate;
  late MockGetDriverCarInfoUseCase mockGet;
  late DriverCarInfoUseCases useCases;
  late DriverCarInfoBloc bloc;

  setUpAll(() {
    registerFallbackValue(const UserEntity.empty().copyWith(id: 1));
    registerFallbackValue(
      CreateDriverCarInfoParams(
        driverCarInfoEntity: DriverCarInfoEntity(
          idDriver: 1,
          brand: '',
          color: '',
          plate: '',
        ),
      ),
    );

    registerFallbackValue(
      AuthResponseEntity(
        user: const UserEntity.empty().copyWith(id: 1),
        token: 'token',
      ),
    );
  });

  setUp(() {
    mockAuth = MockAuthUseCases();
    mockCreate = MockCreateDriverCarInfoUseCase();
    mockGet = MockGetDriverCarInfoUseCase();

    useCases = DriverCarInfoUseCases(
      createDriverCarInfoUseCase: mockCreate,
      getDriverCarInfoUseCase: mockGet,
    );

    bloc = DriverCarInfoBloc(mockAuth, useCases);
  });

  tearDown(() {
    bloc.close();
  });

  final fakeUser = const UserEntity.empty().copyWith(id: 1);
  final fakeAuthResponse = AuthResponseEntity(token: 'tok', user: fakeUser);

  group('Input events', () {
    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'BrandChanged updates brand value in state',
      build: () => bloc,
      act: (b) => b.add(BrandChanged('Mazda')),
      expect: () => [
        isA<DriverCarInfoState>().having(
          (s) => s.brand.value,
          'brand',
          'Mazda',
        ),
      ],
    );
    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'ColorChanged updates color value in state',
      build: () => bloc,
      act: (b) => b.add(ColorChanged('Blue')),
      expect: () => [
        isA<DriverCarInfoState>().having((s) => s.color.value, 'color', 'Blue'),
      ],
    );

    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'PlateChanged updates plate value in state',
      build: () => bloc,
      act: (b) => b.add(PlateChanged('0768 OWJ')),
      expect: () => [
        isA<DriverCarInfoState>().having(
          (s) => s.plate.value,
          'plate',
          '0768 OWJ',
        ),
      ],
    );
  });

  group('SumbitCarInfoChanges', () {
    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'SubmitCarChanges does not call usecase when validation fails',
      build: () => bloc,
      act: (b) => b.add(SubmitCarChanges()),
      verify: (_) {
        verifyNever(() => mockCreate.call(any()));
      },
      expect: () => [
        // we expect the bloc to set hasSubmitted true and set inputs
        // to dirty (they were pure)
        isA<DriverCarInfoState>().having(
          (s) => s.hasSubmitted,
          'hasSubmitted',
          true,
        ),
        isA<DriverCarInfoState>().having(
          (s) => s.hasSubmitted,
          'hasSubmitted',
          true,
        ),
      ],
    );

    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'SubmitCarChanges success flow emits loading then updated state',
      build: () {
        when(
          () => mockCreate.call(any()),
        ).thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) {
        bloc
          ..add(BrandChanged('Mazda'))
          ..add(ColorChanged('Blue'))
          ..add(PlateChanged('0768 OWJ'))
          ..add(SubmitCarChanges());
      },
      wait: const Duration(milliseconds: 50),

      verify: (_) {
        verify(() => mockCreate.call(any())).called(1);

        expect(bloc.state.carInfoUpdated, isTrue);
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.brand.value, 'Mazda');
        expect(bloc.state.color.value, 'Blue');
        expect(bloc.state.plate.value, '0768 OWJ');
      },
    );

    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'when usecase returns Left, bloc ends with errorMessage (no success)',
      build: () {
        when(() => mockCreate.call(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'server error', statusCode: 500),
          ),
        );
        return bloc;
      },
      act: (b) {
        b
          ..add(BrandChanged('Mazda'))
          ..add(ColorChanged('Blue'))
          ..add(PlateChanged('0768 OWJ'))
          ..add(SubmitCarChanges());
      },
      wait: const Duration(milliseconds: 50),

      verify: (_) {
        verify(() => mockCreate.call(any())).called(1);
        // final state should not be success
        expect(bloc.state.carInfoUpdated, isFalse);
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.errorMessage, isNotNull);
      },
    );
  });

  group('LoadCarInfo', () {
    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'when idDriver already in state, calls getDriverCarInfo'
      ' and updates inputs',
      build: () {
        final carEntity = DriverCarInfoEntity(
          idDriver: 1,
          brand: 'Mazda',
          color: 'Red',
          plate: '0768 OWJ',
        );
        when(
          () => mockGet.call(any()),
        ).thenAnswer((_) async => Right(carEntity));
        return bloc;
      },
      act: (b) async {
        b
          ..emit(b.state.copyWith(idDriver: 1))
          ..add(LoadDriverCarInfo());
      },
      wait: const Duration(milliseconds: 50),

      verify: (_) {
        verify(() => mockGet.call(1)).called(1);
        expect(bloc.state.brand.value, 'Mazda');
        expect(bloc.state.color.value, 'Red');
        expect(bloc.state.plate.value, '0768 OWJ');
      },
    );

    blocTest<DriverCarInfoBloc, DriverCarInfoState>(
      'when getDriverCarInfo returns Left, errorMessage is set',
      build: () {
        when(() => mockGet.call(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'server error', statusCode: 500),
          ),
        );
        return bloc;
      },
      act: (b) async {
        b
          ..emit(b.state.copyWith(idDriver: 1))
          ..add(LoadDriverCarInfo());
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) async {
        verify(() => mockGet.call(1)).called(1);
        expect(bloc.state.errorMessage, isNotNull);
      },
    );
  });
}
