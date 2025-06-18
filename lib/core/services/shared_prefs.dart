import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  Future<void> save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value != null) {
      return jsonDecode(value);
    }
    return null;
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
