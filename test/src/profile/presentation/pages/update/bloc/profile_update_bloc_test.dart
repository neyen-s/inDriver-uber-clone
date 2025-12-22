import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/get_user_session_use_case.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/save_user_session_use_case.dart';
import 'package:indriver_uber_clone/src/profile/domain/usecases/update_user_use_case.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_bloc.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/bloc/profile_update_inputs.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthUseCases extends Mock implements AuthUseCases {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockGetUserSessionUseCase extends Mock implements GetUserSessionUseCase {}

class MockSaveUserSessionUseCase extends Mock
    implements SaveUserSessionUseCase {}

void main() {
  late MockAuthUseCases mockAuth;
  late MockUpdateUserUseCase mockUpdateUserUseCase;
  late MockGetUserSessionUseCase mockGetUserSessionUseCase;
  late MockSaveUserSessionUseCase mockSaveUserSessionUseCase;
  late ProfileUpdateBloc bloc;

  setUpAll(() {
    registerFallbackValue(const UserEntity.empty().copyWith(id: 1));
    registerFallbackValue(
      UpdateProfileParams(
        user: const UserEntity.empty().copyWith(id: 1),
        token: 'token123',
      ),
    );
    registerFallbackValue(
      const AuthResponseEntity(token: '', user: UserEntity.empty()),
    );
    registerFallbackValue(const NameInput.dirty());
    registerFallbackValue(const LastnameInput.dirty());
    registerFallbackValue(const PhoneInput.dirty());
  });

  setUp(() {
    mockAuth = MockAuthUseCases();
    mockUpdateUserUseCase = MockUpdateUserUseCase();
    mockGetUserSessionUseCase = MockGetUserSessionUseCase();
    mockSaveUserSessionUseCase = MockSaveUserSessionUseCase();

    when(
      () => mockAuth.getUserSessionUseCase,
    ).thenReturn(mockGetUserSessionUseCase);
    when(
      () => mockAuth.saveUserSessionUseCase,
    ).thenReturn(mockSaveUserSessionUseCase);

    bloc = ProfileUpdateBloc(mockUpdateUserUseCase, mockAuth);
  });

  tearDown(() => bloc.close());

  final fakeAuthUserResponse = AuthResponseEntity.empty();
  final fakeUser = const UserEntity.empty().copyWith(id: 1);

  group('Inputs', () {
    blocTest<ProfileUpdateBloc, ProfileUpdateState>(
      'emits state with updated name',
      build: () => bloc,
      act: (bloc) => bloc.add(const ProfileUpdateNameChanged('Mateo')),
      expect: () => [
        isA<ProfileUpdateState>()
            .having((s) => s.name.value, 'name value', 'Mateo')
            .having((s) => !s.name.isPure, 'name dirty', true)
            .having((s) => s.updateSuccess, 'updateSuccess', false)
            .having((s) => s.errorMessage, 'errorMessage', null),
      ],
    );

    blocTest<ProfileUpdateBloc, ProfileUpdateState>(
      'emits state with updated lastname',
      build: () => bloc,
      act: (bloc) => bloc.add(const ProfileUpdateLastnameChanged('Mateus')),
      expect: () => [
        isA<ProfileUpdateState>()
            .having((s) => s.lastname.value, 'lastname', 'Mateus')
            .having((s) => !s.lastname.isPure, 'lastname dirty', true)
            .having((s) => s.updateSuccess, 'updateSuccess', false)
            .having((s) => s.errorMessage, 'errorMessage', null),
      ],
    );

    blocTest<ProfileUpdateBloc, ProfileUpdateState>(
      'emits state with updated phone',
      build: () => bloc,
      act: (bloc) => bloc.add(const ProfilePhoneChanged('664410988')),
      expect: () => [
        isA<ProfileUpdateState>()
            .having((s) => s.phone.value, 'phone', '664410988')
            .having((s) => s.updateSuccess, 'updateSuccess', false)
            .having((s) => s.errorMessage, 'errorMessage', null),
      ],
    );
  });

  group('On submit changes', () {
    blocTest<ProfileUpdateBloc, ProfileUpdateState>(
      'Submit success emits loading and updates state correctly',
      build: () {
        when(
          () => mockGetUserSessionUseCase.call(),
        ).thenAnswer((_) async => Right(fakeAuthUserResponse));

        when(
          () => mockUpdateUserUseCase.call(any()),
        ).thenAnswer((_) async => Right(fakeUser));

        when(
          () => mockSaveUserSessionUseCase.call(any()),
        ).thenAnswer((_) async => const Right(null));

        return bloc;
      },
      act: (bloc) async {
        bloc
          ..add(const ProfileUpdateNameChanged('Mateo'))
          ..add(const ProfileUpdateLastnameChanged('Perez'))
          ..add(const ProfilePhoneChanged('664410988'))
          ..add(const SubmitProfileChanges());

        await bloc.stream
            .firstWhere((s) => s.updateSuccess || s.errorMessage != null)
            .timeout(const Duration(seconds: 2));
      },
      verify: (_) {
        verify(() => mockGetUserSessionUseCase.call()).called(1);
        verify(() => mockUpdateUserUseCase.call(any())).called(1);
        verify(() => mockSaveUserSessionUseCase.call(any())).called(1);

        expect(bloc.state.updateSuccess, isTrue);
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.errorMessage, isNull);
      },
    );

    blocTest<ProfileUpdateBloc, ProfileUpdateState>(
      'Submit failure sets errorMessage and updateSuccess false',
      build: () {
        when(
          () => mockGetUserSessionUseCase.call(),
        ).thenAnswer((_) async => Right(fakeAuthUserResponse));

        when(() => mockUpdateUserUseCase.call(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'server error', statusCode: 500),
          ),
        );

        return bloc;
      },
      act: (bloc) async {
        bloc
          ..add(const ProfileUpdateNameChanged('Mateo'))
          ..add(const ProfileUpdateLastnameChanged('Perez'))
          ..add(const ProfilePhoneChanged('664410988'))
          ..add(const SubmitProfileChanges());

        await bloc.stream
            .firstWhere((s) => s.updateSuccess || s.errorMessage != null)
            .timeout(const Duration(seconds: 2));
      },
      verify: (_) {
        verify(() => mockGetUserSessionUseCase.call()).called(1);
        verify(() => mockUpdateUserUseCase.call(any())).called(1);

        expect(bloc.state.updateSuccess, isFalse);
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.errorMessage, isNotNull);
      },
    );
  });
}
