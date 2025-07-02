import 'dart:io';

import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';

sealed class ProfileRemoteDataSource {
  const ProfileRemoteDataSource();

  Future<UserDTO> updateProfile(UserDTO user, String token, File? file);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<UserDTO> updateProfile(UserDTO user, String token, File? file) async {
    print({'-----HEADER: Authorization': 'Bearer $token'});
    print({'-----HEADER: 📦 File: ${file?.path}'});

    final response = await apiClient.put(
      path: '/users/upload/${user.id}',
      headers: {'Authorization': 'Bearer $token'},
      fields: {
        'name': user.name,
        'lastname': user.lastname,
        'phone': user.phone,
      },
      file: file,
    );
    print('updateProfile response: ${response}');

    return UserDTO.fromJson(response);
  }
}
