import 'package:formz/formz.dart';

enum PasswordValidationError { empty, tooShort }

class PasswordEntity extends FormzInput<String, PasswordValidationError> {
  const PasswordEntity.pure() : super.pure('');
  const PasswordEntity.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    return value.length >= 6 ? null : PasswordValidationError.tooShort;
  }
}
