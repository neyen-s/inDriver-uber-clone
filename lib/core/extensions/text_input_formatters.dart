import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 2, this.maxIntegerDigits = 4})
    : assert(decimalRange >= 0);

  final int decimalRange;
  final int maxIntegerDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    if (newText.isEmpty) return newValue;

    final regex = RegExp(
      '^\\d{0,$maxIntegerDigits}'
      '${decimalRange > 0 ? '(\\.\\d{0,$decimalRange})?' : ''}'
      r'$',
    );

    if (regex.hasMatch(newText)) {
      return newValue;
    }

    return oldValue;
  }
}
