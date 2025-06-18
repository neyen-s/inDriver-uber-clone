import 'package:formz/formz.dart';

class PhoneEntity extends FormzInput<String, String> {
  const PhoneEntity.pure() : super.pure('');
  const PhoneEntity.dirty([super.value = '']) : super.dirty();

  static final _phoneRegex = RegExp(r'^\+?\d{7,15}$');

  @override
  String? validator(String value) {
    return value.trim().isEmpty
        ? 'Phone number is required'
        : (!_phoneRegex.hasMatch(value.trim()) ? 'Invalid phone number' : null);
  }
}
