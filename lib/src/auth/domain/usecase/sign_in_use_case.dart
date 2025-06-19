import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/usecase/usecase.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class SignInUseCase extends UsecaseWithParams<void, SignInParams> {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<UserEntity> call(SignInParams params) {
    return _repository.signIn(email: params.email, password: params.password);
  }
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
