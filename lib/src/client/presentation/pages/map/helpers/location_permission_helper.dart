import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

typedef OnPermissionGranted = FutureOr<void> Function();

class LocationPermissionHelper {
  static Future<void> ensurePermissionAndInit({
    required BuildContext context,
    required OnPermissionGranted onGranted,
    Duration requestTimeout = const Duration(seconds: 20),
    bool showRationaleIfDenied = true,
  }) async {
    if (!context.mounted) return;
    debugPrint('[LPH] ensurePermissionAndInit START');

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('[LPH] serviceEnabled: $serviceEnabled');
      if (!serviceEnabled) {
        if (!context.mounted) return;

        final open = await _showEnableLocationServiceDialog(context);
        if (open ?? false) {
          await Geolocator.openLocationSettings();
        }
        debugPrint('[LPH] location service disabled -> returning');
        return;
      }

      var permission = await Geolocator.checkPermission();
      debugPrint('[LPH] checkPermission -> $permission');

      // Permanently denied -> open settings flow
      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return;

        await _showOpenSettingsDialog(context);
        return;
      }

      // If denied -> show rationale optionally then request
      if (permission == LocationPermission.denied) {
        if (showRationaleIfDenied) {
          if (!context.mounted) return;

          final ok = await _showPermissionRationaleDialog(context);
          if (!ok) {
            if (!context.mounted) return;

            _showSimpleMessage(
              context,
              'The app needs location permission to function properly.',
            );
            return;
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
          if (!context.mounted) return;

          _showPermissionDeniedSnackBar(context);
          return;
        } else if (result == LocationPermission.deniedForever) {
          if (!context.mounted) return;

          await _showOpenSettingsDialog(context);
          return;
        }
        // else: granted or while-in-use -> continue
      }

      // At this point permission is either 'whileInUse' or 'always' (granted)
      permission = await Geolocator.checkPermission();
      debugPrint('[LPH] final permission check -> $permission');

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // call the provided callback
        // (typically dispatch GetCurrentPositionRequested)
        await onGranted();
      } else {
        debugPrint('[LPH] permission still not granted -> showing message');
        if (!context.mounted) return;

        _showSimpleMessage(
          context,
          'Location permission not granted. Enable it in Settings.',
        );
      }
    } catch (e, st) {
      if (!context.mounted) return;

      debugPrint('[LPH] Error checking permission: $e\n$st');
      _showSimpleMessage(context, 'Error checking permissions: $e');
    } finally {
      debugPrint('[LPH] ensurePermissionAndInit END');
    }
  }

  // Call this from didChangeAppLifecycleState when state == resumed
  static Future<void> onAppResumed({
    required BuildContext context,
    required OnPermissionGranted onGranted,
  }) {
    debugPrint('[LPH] onAppResumed invoked');
    return ensurePermissionAndInit(context: context, onGranted: onGranted);
  }

  // ----------------- Dialogs & helpers -----------------
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
