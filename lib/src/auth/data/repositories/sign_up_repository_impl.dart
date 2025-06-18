import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/sign-up/source/sign_up_remote_datasource.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/sign-up/sign_up_repository.dart';

class SignUpRepositoryImpl implements SignUpRepository {
  const SignUpRepositoryImpl({required this.signUpRemoteDataSource});

  final SignUpRemoteDataSource signUpRemoteDataSource;

  @override
  ResultFuture<UserEntity> signUp({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final user = await signUpRemoteDataSource.signUp(
        name: name,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}
