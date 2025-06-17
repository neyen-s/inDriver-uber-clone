import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalid }

class EmailEntity extends FormzInput<String, EmailValidationError> {
  const EmailEntity.pure() : super.pure('');
  const EmailEntity.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    return _emailRegex.hasMatch(value) ? null : EmailValidationError.invalid;
  }
}
