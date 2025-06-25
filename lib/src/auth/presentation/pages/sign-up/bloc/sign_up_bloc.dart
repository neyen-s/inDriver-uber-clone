import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/confirm_password_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/email_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/last_name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/name_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/password_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/form-entities/phone_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/sign_up_use_case.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this.authUseCases) : super(const SignUpInitial()) {
    on<SignUpNameChanged>(_onNameChanged);
    on<SignUpLastNameChanged>(_onLastnameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPhoneChanged>(_onPhoneChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SaveUserSession>(_onSaveUserSession);
    on<SignUpSubmitted>(_onSubmitted);
  }
  final AuthUseCases authUseCases;

  NameEntity _name = const NameEntity.pure();
  LastnameEntity _lastname = const LastnameEntity.pure();
  EmailEntity _email = const EmailEntity.pure();
  PhoneEntity _phone = const PhoneEntity.pure();
  PasswordEntity _password = const PasswordEntity.pure();
  ConfirmPasswordEntity _confirmPassword = const ConfirmPasswordEntity.pure();

  void _onNameChanged(SignUpNameChanged event, Emitter<SignUpState> emit) {
    _name = NameEntity.dirty(event.name);
    _emitValidationState(emit);
  }

  void _onLastnameChanged(
    SignUpLastNameChanged event,
    Emitter<SignUpState> emit,
  ) {
    _lastname = LastnameEntity.dirty(event.lastName);
    _emitValidationState(emit);
  }

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    _email = EmailEntity.dirty(event.email);
    _emitValidationState(emit);
  }

  void _onPhoneChanged(SignUpPhoneChanged event, Emitter<SignUpState> emit) {
    _phone = PhoneEntity.dirty(event.phone);
    _emitValidationState(emit);
  }

  void _onPasswordChanged(
    SignUpPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    _password = PasswordEntity.dirty(event.password);
    _confirmPassword = _confirmPassword.copyWith(password: _password.value);
    _emitValidationState(emit);
  }

  void _onConfirmPasswordChanged(
    SignUpConfirmPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    _confirmPassword = ConfirmPasswordEntity.dirty(
      password: _password.value,
      value: event.confirmPassword,
    );
    _emitValidationState(emit);
  }

  void _emitValidationState(Emitter<SignUpState> emit) {
    final isValid = Formz.validate([
      _name,
      _lastname,
      _email,
      _phone,
      _password,
      _confirmPassword,
    ]);

    emit(
      SignUpValidating(
        name: _name,
        lastName: _lastname,
        email: _email,
        phone: _phone,
        password: _password,
        confirmPassword: _confirmPassword,
        isValid: isValid,
      ),
    );
  }

  Future<void> _onSaveUserSession(
    SaveUserSession event,
    Emitter<SignUpState> emit,
  ) async {
    await authUseCases.saveUserSessionUseCase(event.authResponse);
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    _email = EmailEntity.dirty(_email.value);
    _password = PasswordEntity.dirty(_password.value);
    _confirmPassword = ConfirmPasswordEntity.dirty(
      password: _password.value,
      value: _confirmPassword.value,
    );
    _name = NameEntity.dirty(_name.value);
    _lastname = LastnameEntity.dirty(_lastname.value);
    _phone = PhoneEntity.dirty(_phone.value);

    final isValid = Formz.validate([
      _email,
      _password,
      _confirmPassword,
      _name,
      _lastname,
      _phone,
    ]);

    // Emitir estado de validación (aunque sea inválido)
    emit(
      SignUpValidating(
        email: _email,
        password: _password,
        confirmPassword: _confirmPassword,
        name: _name,
        lastName: _lastname,
        phone: _phone,
        isValid: isValid,
      ),
    );

    if (!isValid) return;

    emit(
      SignUpSubmitting(
        email: _email,
        password: _password,
        confirmPassword: _confirmPassword,
        name: _name,
        lastName: _lastname,
        phone: _phone,
      ),
    );

    final result = await authUseCases.signUpUseCase(
      SignUpParams(
        email: _email.value,
        password: _password.value,
        name: _name.value,
        lastName: _lastname.value,
        phone: _phone.value,
      ),
    );

    result.fold(
      (failure) => emit(
        SignUpFailure(
          email: _email,
          password: _password,
          confirmPassword: _confirmPassword,
          name: _name,
          lastName: _lastname,
          phone: _phone,
          message: failure.errorMessage,
        ),
      ),
      (response) => emit(SignUpSuccess(authResponse: response)),
    );
  }
}
