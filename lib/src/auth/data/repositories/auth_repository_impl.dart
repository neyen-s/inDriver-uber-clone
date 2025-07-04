import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/mappers/auth_response_mapper.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/sesion_manager.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/source/auth_remote_datasource.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.authRemoteDataSource,
    //  required this.sharedPrefs,
  });

  final AuthRemoteDataSource authRemoteDataSource;
  // final SharedPrefs sharedPrefs;

  @override
  ResultFuture<AuthResponseEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.signIn(
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

  @override
  ResultFuture<AuthResponseEntity> signUp({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.signUp(
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

  @override
  ResultFuture<AuthResponseDTO> getUserSession() async {
    try {
      final data = await SessionManager.getSession();

      if (data != null) {
        return Right(data);
      } else {
        return const Left(
          CacheFaliure(message: 'No user session found', statusCode: 404),
        );
      }
    } on CacheException catch (e) {
      return Left(CacheFaliure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> saveUserSession(AuthResponseEntity authresponse) async {
    try {
      await SessionManager.saveSession(authresponse.toDto());

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFaliure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      await SessionManager.clearSession();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFaliure(message: e.message, statusCode: e.statusCode));
    }
  }
}
