import 'package:formz/formz.dart';
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
    required this.isValid,
    required this.isSubmitting,
    this.error,
  });

  factory SignUpViewModel.fromState(SignUpState state) {
    var name = const NameEntity.pure();
    var lastname = const LastnameEntity.pure();
    var email = const EmailEntity.pure();
    var phone = const PhoneEntity.pure();
    var password = const PasswordEntity.pure();
    var confirmPassword = const ConfirmPasswordEntity.pure();
    var isValid = false;
    var isSubmitting = false;
    String? error;

    if (state is SignUpValidating) {
      name = state.name;
      lastname = state.lastName;
      email = state.email;
      phone = state.phone;
      password = state.password;
      confirmPassword = state.confirmPassword;
      isValid = state.isValid;
    } else if (state is SignUpLoading) {
      name = state.name;
      lastname = state.lastName;
      email = state.email;
      phone = state.phone;
      password = state.password;
      confirmPassword = state.confirmPassword;
      isSubmitting = true;
      isValid = Formz.validate([
        name,
        lastname,
        email,
        phone,
        password,
        confirmPassword,
      ]);
    } else if (state is SignUpFailure) {
      name = state.name;
      lastname = state.lastName;
      email = state.email;
      phone = state.phone;
      password = state.password;
      confirmPassword = state.confirmPassword;

      isValid = Formz.validate([
        name,
        lastname,
        email,
        phone,
        password,
        confirmPassword,
      ]);
      isSubmitting = false;
      error = state.message;
    }

    return SignUpViewModel(
      name: name,
      lastname: lastname,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      isValid: isValid,
      isSubmitting: isSubmitting,
      error: error,
    );
  }

  final NameEntity name;
  final LastnameEntity lastname;
  final EmailEntity email;
  final PhoneEntity phone;
  final PasswordEntity password;
  final ConfirmPasswordEntity confirmPassword;
  final bool isValid;
  final bool isSubmitting;
  final String? error;
}
