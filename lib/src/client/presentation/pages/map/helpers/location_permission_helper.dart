import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

typedef OnPermissionGranted = FutureOr<void> Function();

class LocationPermissionHelper {
  /// Intenta asegurar permiso y devuelve true si ya está concedido (o se acaba de conceder).
  /// No lanza; gestiona internamente diálogos, pero deja al caller decidir qué hacer.
  static Future<bool> ensurePermissionAndInit({
    required BuildContext context,
    Duration requestTimeout = const Duration(seconds: 20),
    bool showRationaleIfDenied = true,
  }) async {
    if (!context.mounted) return false;
    debugPrint('[LPH] ensurePermissionAndInit START');

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('[LPH] serviceEnabled: $serviceEnabled');
      if (!serviceEnabled) {
        if (!context.mounted) return false;
        final open = await _showEnableLocationServiceDialog(context);
        if (open ?? false) {
          await Geolocator.openLocationSettings();
        }
        debugPrint('[LPH] location service disabled -> returning false');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      debugPrint('[LPH] checkPermission -> $permission');

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return false;
        await _showOpenSettingsDialog(context);
        return false;
      }

      if (permission == LocationPermission.denied) {
        // opcional: mostrar rationale y pedir permiso
        if (showRationaleIfDenied) {
          if (!context.mounted) return false;
          final ok = await _showPermissionRationaleDialog(context);
          if (!ok) {
            if (!context.mounted) return false;
            _showSimpleMessage(
              context,
              'The app needs location permission to function properly.',
            );
            return false;
          }
        }

        LocationPermission result;
        try {
          result = await Geolocator.requestPermission().timeout(
            requestTimeout,
            onTimeout: () {
              debugPrint('[LPH] requestPermission timed out');
              return LocationPermission.denied;
            },
          );
        } catch (e, st) {
          debugPrint('[LPH] requestPermission threw: $e\n$st');
          result = LocationPermission.denied;
        }

        debugPrint('[LPH] requestPermission result -> $result');

        if (result == LocationPermission.denied) {
          if (!context.mounted) return false;
          _showPermissionDeniedSnackBar(context);
          return false;
        } else if (result == LocationPermission.deniedForever) {
          if (!context.mounted) return false;
          await _showOpenSettingsDialog(context);
          return false;
        }
        // otherwise fallthrough to final check
      }

      // final check
      permission = await Geolocator.checkPermission();
      debugPrint('[LPH] final permission check -> $permission');

      final granted =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!granted) {
        if (!context.mounted) return false;
        _showSimpleMessage(
          context,
          'Location permission not granted. Enable it in Settings.',
        );
        return false;
      }

      // OK: permission granted
      return true;
    } catch (e, st) {
      if (!context.mounted) return false;
      debugPrint('[LPH] Error checking permission: $e\n$st');
      _showSimpleMessage(context, 'Error checking permissions: $e');
      return false;
    } finally {
      debugPrint('[LPH] ensurePermissionAndInit END');
    }
  }

  // Helper que llama desde didChangeAppLifecycleState
  static Future<void> onAppResumed({
    required BuildContext context,
    required OnPermissionGranted onGranted,
  }) async {
    debugPrint('[LPH] onAppResumed invoked');
    final ok = await ensurePermissionAndInit(context: context);
    if (ok) {
      await onGranted();
    }
  }

  // ----------------- Dialogs & helpers (sin cambios) -----------------
  static Future<bool?> _showEnableLocationServiceDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location disabled'),
        content: const Text(
          'Location services are turned off. Enable location to find'
          ' nearby drivers and create trips.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  static Future<bool> _showPermissionRationaleDialog(
    BuildContext context,
  ) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Location permission'),
        content: const Text(
          'We need permission to access your location to show nearby drivers'
          ' and calculate routes. Do you want to allow access?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  static Future<void> _showOpenSettingsDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission permanently denied'),
        content: const Text(
          'You have permanently denied location permission.'
          ' Open the app settings to enable it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  static void _showSimpleMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void _showPermissionDeniedSnackBar(BuildContext context) {
    if (!context.mounted) return;
    const snack = SnackBar(
      content: Text('Location permission denied. Enable it in Settings.'),
      action: SnackBarAction(
        label: 'Open settings',
        onPressed: Geolocator.openAppSettings,
      ),
      duration: Duration(seconds: 6),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
