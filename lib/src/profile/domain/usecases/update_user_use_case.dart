import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/profile/domain/repository/profile_repository.dart';

class UpdateUserUseCase extends UsecaseWithParams<void, UpdateProfileParams> {
  const UpdateUserUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  ResultFuture<UserEntity> call(UpdateProfileParams params) {
    return _repository.updateUser(params.user, params.token, params.file);
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    required this.user,
    required this.token,
    this.file,
  });

  final UserEntity user;
  final String token;
  final File? file;

  @override
  List<Object?> get props => [user, token, file];
}
