double? parseToDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final s = value.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

int? toIntSafe(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) {
    final s = value.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }
  return null;
}
