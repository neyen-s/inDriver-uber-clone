part of 'sign_up_bloc.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

final class SignUpInitial extends SignUpState {
  const SignUpInitial();
}

final class SignUpValidating extends SignUpState {
  const SignUpValidating({
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.isValid,
  });
  final NameEntity name;
  final LastnameEntity lastName;
  final EmailEntity email;
  final PhoneEntity phone;
  final PasswordEntity password;
  final ConfirmPasswordEntity confirmPassword;
  final bool isValid;

  @override
  List<Object> get props => [name, lastName, email, phone, password, isValid];
}

final class SignUpSubmitting extends SignUpState {
  const SignUpSubmitting({
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });
  final NameEntity name;
  final LastnameEntity lastName;
  final EmailEntity email;
  final PhoneEntity phone;
  final PasswordEntity password;
  final ConfirmPasswordEntity confirmPassword;

  @override
  List<Object> get props => [name, lastName, email, phone, password];
}

final class SignUpSuccess extends SignUpState {
  const SignUpSuccess();

  @override
  List<Object> get props => [];
}

final class SignUpFailure extends SignUpState {
  const SignUpFailure({
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.message,
  });
  final NameEntity name;
  final LastnameEntity lastName;
  final EmailEntity email;
  final PhoneEntity phone;
  final PasswordEntity password;
  final ConfirmPasswordEntity confirmPassword;
  final String message;

  @override
  List<Object> get props => [name, lastName, email, phone, password, message];
}
