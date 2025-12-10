import 'package:formz/formz.dart';

class NameInput extends FormzInput<String, String> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  bool get isInvalid => validator(value) != null;
  @override
  String? get error => validator(value);
}

class LastnameInput extends FormzInput<String, String> {
  const LastnameInput.pure() : super.pure('');
  const LastnameInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Last name is required';
    if (v.length < 2) return 'Last name is too short';
    return null;
  }

  bool get isInvalid => validator(value) != null;
  @override
  String? get error => validator(value);
}

class PhoneInput extends FormzInput<String, String> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([super.value = '']) : super.dirty();

  static final _phoneRegex = RegExp(r'^\+?\d{7,15}$');

  @override
  String? validator(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Phone number is required';
    if (!_phoneRegex.hasMatch(v)) return 'Invalid phone number';
    return null;
  }

  bool get isInvalid => validator(value) != null;
  @override
  String? get error => validator(value);
}

enum EmailValidationError { empty, invalid }

class EmailInput extends FormzInput<String, EmailValidationError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    return _emailRegex.hasMatch(value) ? null : EmailValidationError.invalid;
  }
}

enum PasswordValidationError { empty, tooShort }

class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    return value.length >= 6 ? null : PasswordValidationError.tooShort;
  }
}

class ConfirmPasswordInput extends FormzInput<String, String> {
  const ConfirmPasswordInput.pure({this.password = ''}) : super.pure('');
  const ConfirmPasswordInput.dirty({
    required this.password,
    required String value,
  }) : super.dirty(value);

  final String password;

  @override
  String? validator(String value) {
    return value != password ? 'Passwords do not match' : null;
  }

  ConfirmPasswordInput copyWith({String? password, String? value}) {
    return ConfirmPasswordInput.dirty(
      password: password ?? this.password,
      value: value ?? this.value,
    );
  }
}
