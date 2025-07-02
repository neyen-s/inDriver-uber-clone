import 'dart:io';

import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  const ProfileRepository();

  ResultFuture<UserEntity> updateUser(
    UserEntity user,
    String token,
    File? imageFile,
  );
}
