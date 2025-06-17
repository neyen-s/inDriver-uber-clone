import 'dart:async';

import 'package:indriver_uber_clone/core/network/api_client.dart';

import 'package:indriver_uber_clone/data/datasource/auth/sign-in/remote/auth_response_dto.dart';

import 'package:indriver_uber_clone/domain/entities/auth/user_entity.dart';

abstract class SignInRemoteDataSource {
  const SignInRemoteDataSource();

  Future<UserEntity> signIn({required String email, required String password});
}

class SignInRemoteDataSourceImpl implements SignInRemoteDataSource {
  SignInRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final data = await apiClient.post(
      path: '/auth/login',
      body: {'email': email, 'password': password},
    );

    final authResponse = AuthResponseDTO.fromJson(data);
    return authResponse.user;
  }
}
