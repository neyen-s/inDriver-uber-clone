import 'package:flutter/services.dart';

String? validatePrice(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // No molestar si aún no se escribió nada
  }

  final trimmed = value.trim();

  // Expresión regular: números con máximo 2 decimales
  final regex = RegExp(r'^\d+(\.\d{1,2})?$');
  if (!regex.hasMatch(trimmed)) {
    return 'Enter a valid price (max 2 decimals)';
  }

  final parsed = double.tryParse(trimmed);
  if (parsed == null || parsed <= 0) {
    return 'Price must be greater than zero';
  }

  if (parsed >= 10000) {
    return 'Price must be less than 10000';
  }

  return null;
}
