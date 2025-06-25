import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class SharedPrefsAdapter {
  static Future<void> saveDto(String key, Map<String, dynamic> dto) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(dto);
    await prefs.setString(key, jsonString);
  }

  static Future<T?> readDto<T>(String key, FromJson<T> fromJson) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
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

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
