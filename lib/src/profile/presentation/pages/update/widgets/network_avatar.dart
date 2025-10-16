import 'package:flutter/material.dart';

/// Normaliza una URL para evitar dobles slashes después del host:
/// - si la url está vacía devuelve null.
/// - si no empieza por http(s) la devuelve sin tocar (caller decide).
String? _normalizeUrl(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  // Si la URL no tiene scheme devolvemos la original (no forzamos agregar host aquí)
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return trimmed;
  }

  // Separar scheme://rest para mantener exactamente el scheme y evitar eliminar '://'
  final idx = trimmed.indexOf('://');
  if (idx < 0) return trimmed;

  final scheme = trimmed.substring(0, idx + 3); // 'http://'
  var rest = trimmed.substring(idx + 3);

  // Reemplazar secuencias de slashes múltiples por una sola slash en el resto
  rest = rest.replaceAll(RegExp('/{2,}'), '/');

  return '$scheme$rest';
}

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({
    required this.imageUrl,
    super.key,
    this.size = 56,
    this.assetFallback = 'assets/img/user.png',
    this.fit = BoxFit.cover,
  });
  final String? imageUrl;
  final double size;
  final String assetFallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeUrl(imageUrl);

    final widgetImage =
        (normalized != null &&
            normalized.isNotEmpty &&
            (normalized.startsWith('http://') ||
                normalized.startsWith('https://')))
        ? Image.network(
            normalized,
            fit: fit,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stack) {
              return Image.asset(assetFallback, fit: fit);
            },
          )
        : Image.asset(assetFallback, fit: fit);

    return ClipOval(
      child: SizedBox(width: size, height: size, child: widgetImage),
    );
  }
}
