import 'package:flutter/material.dart';

/// Normalices Url to avoid double slashes after the host:
/// - if empty return null.
/// - if it dosnt start with http(s) returns it normally.
String? _normalizeUrl(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  //If the url dosnt have scheme return it normally
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return trimmed;
  }

  // Separates scheme://rest to keep exactly the scheme and avoid removing '://'
  final idx = trimmed.indexOf('://');
  if (idx < 0) return trimmed;

  final scheme = trimmed.substring(0, idx + 3); // 'http://'
  var rest = trimmed.substring(idx + 3);

  // Reemplazar secuencias de slashes múltiples por una sola slash en el resto
  //replaces
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
