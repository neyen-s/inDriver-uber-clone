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
  const SignInSuccess({required this.authResponse});

  final AuthResponseEntity authResponse;
  @override
  List<Object> get props => [authResponse];
}

class SignInFailure extends SignInState {
  const SignInFailure({
    required this.email,
    required this.password,
    required this.message,
  });
  final EmailEntity email;
  final PasswordEntity password;
  final String message;

  @override
  List<Object> get props => [email, password, message];
}

class SessionValid extends SignInState {
  const SessionValid(this.authResponse);
  final AuthResponseEntity authResponse;

  @override
  List<Object> get props => [authResponse];
}

class SessionInvalid extends SignInState {}
