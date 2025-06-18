import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/email_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/password_entity.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';

class SignInViewModel {
  const SignInViewModel({
    required this.email,
    required this.password,
    this.isSubmitting = false,
    this.isValid = false,
    this.error,
  });

  factory SignInViewModel.fromState(SignInState state) {
    if (state is SignInValidating) {
      return SignInViewModel(
        email: state.email,
        password: state.password,
        isValid: state.isValid,
      );
    } else if (state is SignInSubmitting) {
      return SignInViewModel(
        email: state.email,
        password: state.password,
        isSubmitting: true,
      );
    } else if (state is SignInFailure) {
      return SignInViewModel(
        email: state.email,
        password: state.password,
        error: state.message,
      );
    } else {
      return const SignInViewModel(
        email: EmailEntity.pure(),
        password: PasswordEntity.pure(),
      );
    }
  }
  final EmailEntity email;
  final PasswordEntity password;
  final bool isSubmitting;
  final bool isValid;
  final String? error;
}
