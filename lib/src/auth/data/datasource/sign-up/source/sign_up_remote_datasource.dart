import 'package:indriver_uber_clone/core/network/api_client.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/sign-in/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';

abstract class SignUpRemoteDataSource {
  const SignUpRemoteDataSource();

  /// Signs up a user with the provided [email], [password], and [name].
  ///
  /// Returns a [Future] containing a [UserEntity]
  /// on success or an error on failure.
  Future<UserEntity> signUp({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
}

class SignUpRemoteDataSourceImpl extends SignUpRemoteDataSource {
  const SignUpRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

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
