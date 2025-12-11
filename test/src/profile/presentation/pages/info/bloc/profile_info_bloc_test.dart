import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/get_user_session_use_case.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/info/bloc/profile_info_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUserSessionUseCase extends Mock implements GetUserSessionUseCase {}

void main() {
  late MockGetUserSessionUseCase mockGetUserSessionUseCase;
  late ProfileInfoBloc bloc;

  final tAuthResponseEntity = AuthResponseEntity.empty();

  setUpAll(() {
    registerFallbackValue(tAuthResponseEntity);
  });

  setUp(() {
    mockGetUserSessionUseCase = MockGetUserSessionUseCase();
    bloc = ProfileInfoBloc(mockGetUserSessionUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('getUserSession', () {
    blocTest<ProfileInfoBloc, ProfileInfoState>(
      'emits [ProfileInfoLoaded] when getUserSession is called',
      build: () {
        when(
          () => mockGetUserSessionUseCase.call(),
        ).thenAnswer((_) async => Right(tAuthResponseEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadUserProfile()),
      expect: () => [
        const ProfileInfoLoading(),
        ProfileInfoLoaded(tAuthResponseEntity),
      ],
      verify: (_) {
        verify(() => mockGetUserSessionUseCase.call()).called(1);
      },
    );

    blocTest<ProfileInfoBloc, ProfileInfoState>(
      'emits [ProfileInfoError] when getUserSession fails',
      build: () {
        const failure = ServerFailure(statusCode: 500, message: 'server error');
        when(
          () => mockGetUserSessionUseCase.call(),
        ).thenAnswer((_) async => const Left(failure));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadUserProfile()),
      expect: () => [
        const ProfileInfoLoading(),
        ProfileInfoError(
          const ServerFailure(
            statusCode: 500,
            message: 'server error',
          ).errorMessage,
        ),
      ],
      verify: (_) {
        verify(() => mockGetUserSessionUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetUserSessionUseCase);
      },
    );
  });
}
