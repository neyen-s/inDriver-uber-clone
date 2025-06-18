import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/sign-in/source/sign_in_remote_datasource.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/sign-in/sign_in_repository.dart';

class SignInRepositoryImpl implements SignInRepository {
  const SignInRepositoryImpl({required this.signInRemoteDataSource});

  final SignInRemoteDataSource signInRemoteDataSource;

  @override
  ResultFuture<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await signInRemoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: e));
    }
  }
}
