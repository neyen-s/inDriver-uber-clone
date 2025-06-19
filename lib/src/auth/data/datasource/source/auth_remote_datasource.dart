import 'dart:async';

import 'package:indriver_uber_clone/core/network/api_client.dart';

import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';

import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<AuthResponseDTO> signIn({
    required String email,
    required String password,
  });

  Future<UserEntity> signUp({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<AuthResponseDTO> signIn({
    required String email,
    required String password,
  }) async {
    final data = await apiClient.post(
      path: '/auth/login',
      body: {'email': email, 'password': password},
    );

    final authResponse = AuthResponseDTO.fromJson(data);
    return authResponse;
  }

  @override
  Future<UserEntity> signUp({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await apiClient.post(
      path: '/auth/register',
      body: {
        'name': name,
        'lastname': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    final response = UserDTO.fromJson(data);
    return response;
  }
}
