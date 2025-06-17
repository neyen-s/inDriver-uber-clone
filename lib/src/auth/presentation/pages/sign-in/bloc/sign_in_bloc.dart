import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/email_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/password_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_in_use_case.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc(this.signInUseCase) : super(const SignInInitial()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
  }

  final SignInUseCase signInUseCase;

  EmailEntity _email = const EmailEntity.pure();
  PasswordEntity _password = const PasswordEntity.pure();

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    _email = EmailEntity.dirty(event.email);
    final isValid = Formz.validate([_email, _password]);
    emit(
      SignInValidating(email: _email, password: _password, isValid: isValid),
    );
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    _password = PasswordEntity.dirty(event.password);
    final isValid = Formz.validate([_email, _password]);
    emit(
      SignInValidating(email: _email, password: _password, isValid: isValid),
    );
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    _email = EmailEntity.dirty(_email.value);
    _password = PasswordEntity.dirty(_password.value);

    final isValid = Formz.validate([_email, _password]);

    if (!isValid) {
      emit(
        SignInValidating(email: _email, password: _password, isValid: false),
      );
      return;
    }

    emit(SignInSubmitting(email: _email, password: _password));

    final result = await signInUseCase(
      SignInParams(email: _email.value, password: _password.value),
    );
    result.fold(
      (failure) {
        emit(
          SignInFailure(
            email: _email,
            password: _password,
            message: failure.errorMessage,
          ),
        );
      },
      (_) {
        emit(SignInSuccess());
      },
    );
  }
}
