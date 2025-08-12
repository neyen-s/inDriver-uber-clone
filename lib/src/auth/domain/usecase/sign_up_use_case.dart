import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class SignUpUseCase extends UsecaseWithParams<void, SignUpParams> {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<AuthResponseEntity> call(SignUpParams params) {
    return _repository.signUp(
      name: params.name,
      lastName: params.lastName,
      email: params.email,
      phone: params.phone,
      password: params.password,
    );
  }
}

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String name;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  @override
  List<Object?> get props => [name, lastName, email, phone, password];
}
