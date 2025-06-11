import 'package:formz/formz.dart';

class PasswordEntity extends FormzInput<String, String> {
  const PasswordEntity.pure() : super.pure('');
  const PasswordEntity.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'Campo obligatorio';
    return value.length >= 6 ? null : 'Mínimo 6 caracteres';
  }
}
