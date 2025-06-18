import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/confirm_password_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/email_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/last_name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/password_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/phone_entity.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';

class SignUpViewModel {
  const SignUpViewModel({
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    this.isSubmitting = false,
    this.isValid = false,
    this.error,
  });

  factory SignUpViewModel.fromState(SignUpState state) {
    if (state is SignUpValidating) {
      return SignUpViewModel(
        name: state.name,
        lastname: state.lastName,
        email: state.email,
        phone: state.phone,
        password: state.password,
        confirmPassword: state.confirmPassword,
        isValid: state.isValid,
      );
    } else if (state is SignUpSubmitting) {
      return SignUpViewModel(
        name: state.name,
        lastname: state.lastName,
        email: state.email,
        phone: state.phone,
        password: state.password,
        confirmPassword: state.confirmPassword,
        isSubmitting: true,
      );
    } else if (state is SignUpFailure) {
      return SignUpViewModel(
        name: state.name,
        lastname: state.lastName,
        email: state.email,
        phone: state.phone,
        password: state.password,
        confirmPassword: state.confirmPassword,
        error: state.message,
      );
    } else {
      return const SignUpViewModel(
        name: NameEntity.pure(),
        lastname: LastnameEntity.pure(),
        email: EmailEntity.pure(),
        phone: PhoneEntity.pure(),
        password: PasswordEntity.pure(),
        confirmPassword: ConfirmPasswordEntity.pure(),
      );
    }
  }
  final NameEntity name;
  final LastnameEntity lastname;

  final EmailEntity email;
  final PhoneEntity phone;
  final PasswordEntity password;
  final ConfirmPasswordEntity confirmPassword;
  final bool isSubmitting;
  final bool isValid;
  final String? error;
}
