import 'package:formz/formz.dart';

class LastnameEntity extends FormzInput<String, String> {
  const LastnameEntity.pure() : super.pure('');
  const LastnameEntity.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    return value.trim().isEmpty
        ? 'Last name is required'
        : (value.trim().length < 2 ? 'Last name is too short' : null);
  }
}
