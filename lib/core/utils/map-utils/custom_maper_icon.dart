// core/utils/map-utils/custom_maper_icon.dart
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkerIcon {
  /// logicalSize: tamaño deseado en dp (p.ej. 48, 64, 96).
  static Future<BitmapDescriptor> fromAsset(
    String assetPath, {
    int logicalSize = 48,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final int targetWidth = (logicalSize * ui.window.devicePixelRatio).round();

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
