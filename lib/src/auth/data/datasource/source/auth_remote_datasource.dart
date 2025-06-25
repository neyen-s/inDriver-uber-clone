import 'dart:async';

import 'package:indriver_uber_clone/core/network/api_client.dart';

import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';

abstract class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  Future<AuthResponseDTO> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponseDTO> signUp({
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
  Future<AuthResponseDTO> signUp({
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

    final response = AuthResponseDTO.fromJson(data);
    return response;
  }
}
