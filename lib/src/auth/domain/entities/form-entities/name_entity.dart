import 'package:formz/formz.dart';

class NameEntity extends FormzInput<String, String> {
  const NameEntity.pure() : super.pure('');
  const NameEntity.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    return value.trim().isEmpty
        ? 'Name is required'
        : (value.trim().length < 2 ? 'Name is too short' : null);
  }
}
