String? normalizeUrl(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (!t.startsWith('http://') && !t.startsWith('https://')) return t;
  final idx = t.indexOf('://');
  final scheme = t.substring(0, idx + 3);
  var rest = t.substring(idx + 3);
  rest = rest.replaceAll(RegExp('/{2,}'), '/');
  return '$scheme$rest';
}
