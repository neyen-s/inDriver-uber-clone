import 'package:formz/formz.dart';

class EmailEntity extends FormzInput<String, String> {
  const EmailEntity.pure() : super.pure('');
  const EmailEntity.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  String? validator(String value) {
    if (value.isEmpty) return 'This field is required';
    return _emailRegex.hasMatch(value) ? null : 'Invalid email';
  }
}
