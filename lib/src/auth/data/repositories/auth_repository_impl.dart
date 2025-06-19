import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/services/shared_prefs.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/source/auth_remote_datasource.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.sharedPrefs,
  });

  final AuthRemoteDataSource authRemoteDataSource;
  final SharedPrefs sharedPrefs;

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
  ResultFuture<UserEntity> signUp({
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
      print('------GET USER SESSION-----');

      //TODO TEST THIS!!
      final data = await sharedPrefs.read('user') as Map<String, dynamic>;
      print('DATA:_ $data');

      if (data != null) {
        return Right(AuthResponseDTO.fromJson(data));
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
      final dto = AuthResponseDTO.fromEntity(authresponse);
      await sharedPrefs.save('user', jsonEncode(dto.toJson()));

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFaliure(message: e.message, statusCode: e.statusCode));
    }
  }
}
