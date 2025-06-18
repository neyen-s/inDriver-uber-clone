part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

final class SignUpNameChanged extends SignUpEvent {
  const SignUpNameChanged(this.name);
  final String name;

  @override
  List<Object> get props => [name];
}

final class SignUpLastNameChanged extends SignUpEvent {
  const SignUpLastNameChanged(this.lastName);
  final String lastName;

  @override
  List<Object> get props => [lastName];
}

final class SignUpEmailChanged extends SignUpEvent {
  const SignUpEmailChanged(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

final class SignUpPhoneChanged extends SignUpEvent {
  const SignUpPhoneChanged(this.phone);
  final String phone;

  @override
  List<Object> get props => [phone];
}

final class SignUpPasswordChanged extends SignUpEvent {
  const SignUpPasswordChanged(this.password);
  final String password;

  @override
  List<Object> get props => [password];
}

final class SignUpConfirmPasswordChanged extends SignUpEvent {
  const SignUpConfirmPasswordChanged(this.confirmPassword);
  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

final class SignUpSubmitted extends SignUpEvent {
  const SignUpSubmitted();

  @override
  List<Object> get props => [];
}
