import 'package:formz/formz.dart';

class ConfirmPasswordEntity extends FormzInput<String, String> {
  const ConfirmPasswordEntity.pure({this.password = ''}) : super.pure('');
  const ConfirmPasswordEntity.dirty({
    required this.password,
    required String value,
  }) : super.dirty(value);
  final String password;

  @override
  String? validator(String value) {
    return value != password ? 'Passwords do not match' : null;
  }

  ConfirmPasswordEntity copyWith({String? password, String? value}) {
    return ConfirmPasswordEntity.dirty(
      password: password ?? this.password,
      value: value ?? this.value,
    );
  }
}
