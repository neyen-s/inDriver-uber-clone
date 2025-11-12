import 'package:formz/formz.dart';

class BrandInput extends FormzInput<String, String> {
  const BrandInput.pure() : super.pure('');
  const BrandInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Brand is required';
    if (v.length < 2) return 'Brand is too short';
    return null;
  }

  bool get isInvalid => validator(value) != null;
  @override
  String? get error => validator(value);
}

class ColorInput extends FormzInput<String, String> {
  const ColorInput.pure() : super.pure('');
  const ColorInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.trim().isEmpty) return 'Color is required';
    return null;
  }

  bool get isInvalid => validator(value) != null;
  @override
  String? get error => validator(value);
}

class PlateInput extends FormzInput<String, String> {
  const PlateInput.pure() : super.pure('');
  const PlateInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Plate is required';
    final plateRegex = RegExp(r'^[A-Z0-9\- ]{3,10}$', caseSensitive: false);
    if (!plateRegex.hasMatch(v)) return 'Invalid plate format';
    return null;
  }

  bool get isInvalid => validator(value) != null;
  @override
  String? get error => validator(value);
}
