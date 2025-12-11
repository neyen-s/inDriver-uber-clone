import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/src/profile/domain/repository/profile_repository.dart';
import 'package:indriver_uber_clone/src/profile/domain/usecases/update_user_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository mockRepo;
  late UpdateUserUseCase usecase;

  const testUser = UserEntity.empty();
  const testUserParams = UpdateProfileParams(
    user: UserEntity.empty(),
    token: 'token123',
  );

  setUpAll(() {
    registerFallbackValue(testUser);
    registerFallbackValue(testUserParams);
  });

  setUp(() {
    mockRepo = MockProfileRepository();
    usecase = UpdateUserUseCase(mockRepo);
  });

  test(
    'should forward call to repository and return Right(UserEntity) on success',
    () async {
      when(
        () => mockRepo.updateUser(any(), any(), any()),
      ).thenAnswer((_) async => const Right(testUser));

      final result = await usecase.call(
        const UpdateProfileParams(user: testUser, token: 'token123'),
      );

      result.fold(
        (l) => fail('Expected Right(UserEntity) but got Left($l)'),
        (r) => expect(r, equals(testUser)),
      );

      verify(() => mockRepo.updateUser(testUser, 'token123', null)).called(1);
      verifyNoMoreInteractions(mockRepo);
    },
  );

  test('Returns Left when repository fails', () async {
    const failure = ServerFailure(message: 'server error', statusCode: 500);

    when(
      () => mockRepo.updateUser(any(), any(), any()),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(
      const UpdateProfileParams(user: testUser, token: 'token123'),
    );

    result.fold(
      (l) => expect(l, equals(failure)),
      (r) => fail('Expected Left($failure) but got Right($r)'),
    );

    verify(() => mockRepo.updateUser(testUser, 'token123', null)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
