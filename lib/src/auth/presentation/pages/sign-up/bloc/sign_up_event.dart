part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

final class SignUpNameChanged extends SignUpEvent {
  const SignUpNameChanged(this.name);
  final String name;

}

final class SignUpLastNameChanged extends SignUpEvent {
  const SignUpLastNameChanged(this.lastName);
  final String lastName;

}

final class SignUpEmailChanged extends SignUpEvent {
  const SignUpEmailChanged(this.email);
  final String email;

}

final class SignUpPhoneChanged extends SignUpEvent {
  const SignUpPhoneChanged(this.phone);
  final String phone;
}

final class SignUpPasswordChanged extends SignUpEvent {
  const SignUpPasswordChanged(this.password);
  final String password;
}

final class SignUpConfirmPasswordChanged extends SignUpEvent {
  const SignUpConfirmPasswordChanged(this.confirmPassword);
  final String confirmPassword;
}

class SaveUserSession extends SignUpEvent {
  const SaveUserSession({required this.authResponse});
  final AuthResponseEntity authResponse;
}

final class SignUpSubmitted extends SignUpEvent {
  const SignUpSubmitted();
}
