part of 'sign_in_bloc.dart';

abstract class SignInEvent {}

class SignInEmailChanged extends SignInEvent {
  SignInEmailChanged(this.email);
  final String email;
}

class SignInPasswordChanged extends SignInEvent {
  SignInPasswordChanged(this.password);
  final String password;
}

class SignInSubmitted extends SignInEvent {}
