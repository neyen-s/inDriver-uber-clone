import 'dart:io';

import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

abstract class ProfileRepository {
  const ProfileRepository();

  ResultFuture<UserEntity> updateUser(
    UserEntity user,
    String token,
    File? imageFile,
  );
}
