part of 'sign_up_bloc.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
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
  List<Object?> get props => [
    name,
    lastName,
    email,
    phone,
    password,
    confirmPassword,
    isValid,
  ];
}

final class SignUpLoading extends SignUpState {
  const SignUpLoading({
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
  List<Object?> get props => [
    name,
    lastName,
    email,
    phone,
    password,
    confirmPassword,
  ];
}

final class SignUpSuccess extends SignUpState {
  const SignUpSuccess({required this.authResponse});
  final AuthResponseEntity authResponse;

  @override
  List<Object?> get props => [authResponse];
}

final class SignUpFailure extends SignUpState {
  const SignUpFailure({
    required this.message,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  final String message;
  final NameEntity name;
  final LastnameEntity lastName;
  final EmailEntity email;
  final PhoneEntity phone;
  final PasswordEntity password;
  final ConfirmPasswordEntity confirmPassword;

  @override
  List<Object?> get props => [
    message,
    name,
    lastName,
    email,
    phone,
    password,
    confirmPassword,
  ];
}
