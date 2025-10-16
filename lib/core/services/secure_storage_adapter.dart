import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class SecureStorageAdapter {
  static late final FlutterSecureStorage _instance;

  static Future<void> init({bool encrypted = false}) async {
    _instance = const FlutterSecureStorage();
  }

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  static const AndroidOptions _androidOptions = AndroidOptions.defaultOptions;

  static Future<void> saveDto(String key, Map<String, dynamic> dto) async {
    final jsonString = jsonEncode(dto);
    await _instance.write(
      key: key,
      value: jsonString,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  static Future<T?> readDto<T>(String key, FromJson<T> fromJson) async {
    final jsonString = await _instance.read(
      key: key,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
    if (jsonString == null) return null;
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return fromJson(decoded);
    } else {
      throw const FormatException(
        'Stored JSON is not a valid Map<String, dynamic>',
      );
    }
  }

  static Future<void> writeToken(String key, String? value) async {
    if (value == null) return;
    await _instance.write(
      key: key,
      value: value,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  static Future<String?> readToken(String key) async {
    return _instance.read(
      key: key,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  static Future<void> delete(String key) async => _instance.delete(
    key: key,
    iOptions: _iosOptions,
    aOptions: _androidOptions,
  );
  static Future<void> deleteAll() async =>
      _instance.deleteAll(iOptions: _iosOptions, aOptions: _androidOptions);
  static Future<bool> contains(String key) async {
    final val = await _instance.read(
      key: key,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
    return val != null;
  }
}
