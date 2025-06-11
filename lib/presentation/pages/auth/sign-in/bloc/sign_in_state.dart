part of 'sign_in_bloc.dart';

abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {
  const SignInInitial();
}

class SignInValidating extends SignInState {
  const SignInValidating({
    required this.email,
    required this.password,
    required this.isValid,
  });
  final EmailEntity email;
  final PasswordEntity password;
  final bool isValid;

  @override
  List<Object> get props => [email, password, isValid];
}

class SignInSubmitting extends SignInState {
  const SignInSubmitting({required this.email, required this.password});
  final EmailEntity email;
  final PasswordEntity password;

  @override
  List<Object> get props => [email, password];
}

class SignInSuccess extends SignInState {
  @override
  List<Object> get props => [];
}

class SignInFailure extends SignInState {
  const SignInFailure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
