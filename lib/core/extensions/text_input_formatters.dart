import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange = 2, this.maxIntegerDigits = 4})
    : assert(decimalRange >= 0, 'Decimal range must be non-negative');

  final int decimalRange;
  final int maxIntegerDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    // Si el nuevo texto está vacío, simplemente lo devolvemos
    if (newText.isEmpty) return newValue;

    // Verificamos si el valor es válido según la expresión regular
    // Note: This regex only allows a period (.) as the decimal separator.
    // For locales using a comma, consider making the separator configurable.
    final regex = RegExp(
      '^\\d{0,$maxIntegerDigits}${decimalRange > 0 ? '(\\.\\d{0,$decimalRange})?' : ''}\$',
    );

    // Si no coincide con la expresión regular, devolvemos el valor anterior
    if (!regex.hasMatch(newText)) {
      return oldValue;
    }

    // Verificamos si el valor es mayor que 0
    final parsedValue = double.tryParse(newText);
    if (parsedValue == null || parsedValue <= 0) {
      return oldValue; // Rechaza si no se puede parsear o es <= 0
    }

    return newValue; // Acepta el valor si pasa ambas validaciones
  }
}
