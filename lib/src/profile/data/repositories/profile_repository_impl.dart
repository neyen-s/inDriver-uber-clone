import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/errors/error_mapper.dart';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/mappers/user_mapper.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/profile/data/datasource/source/profile_remote_datasource.dart';
import 'package:indriver_uber_clone/src/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this.profileRemoteDataSource});

  final ProfileRemoteDataSource profileRemoteDataSource;

  @override
  ResultFuture<UserDTO> updateUser(
    UserEntity user,
    String token,
    File? file,
  ) async {
    try {
      final userDTO = await profileRemoteDataSource.updateProfile(
        user.toDto(),
        token,
        file,
      );
      return Right(userDTO);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
