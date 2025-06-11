// sign_in_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:indriver_uber_clone/domain/entities/auth/email_entity.dart';
import 'package:indriver_uber_clone/domain/entities/auth/password_entity.dart';

import '../../../../domain/use_cases/sign_in_use_case.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc(this.signInUseCase) : super(const SignInInitial()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
  }

  final SignInUseCase signInUseCase;
  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    final email = EmailEntity.dirty(event.email);
    final password = state.password;

    emit(
      SignInValidating(
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      ),
    );
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    final password = PasswordEntity.dirty(event.password);
    final email = state.email;

    emit(
      SignInValidating(
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      ),
    );
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    final email = EmailEntity.dirty(state.email.value);
    final password = PasswordEntity.dirty(state.password.value);
    final isValid = Formz.validate([email, password]);

    if (!isValid) {
      emit(SignInValidating(email: email, password: password, isValid: false));
      return;
    }

    emit(SignInSubmitting(email: email, password: password));

    try {
      await signInUseCase(email: email.value, password: password.value);
      emit(SignInSuccess());
    } catch (e) {
      emit(SignInFailure(e.toString()));
    }
  }
}
