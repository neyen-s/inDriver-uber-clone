import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/secure_storage_adapter.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';

class SessionManager {
  static AuthResponseDTO? _session;
  static const _sessionUserKey = 'user';
  static const _accessKey = 'access_token';
  static const refreshKey = 'refresh_token';

  static const String _refreshPath = '/auth/refresh';

  static Future<void> saveSession(AuthResponseDTO session) async {
    _session = session;
    final userMap = session.user is UserDTO
        ? (session.user as UserDTO).toJson()
        : UserDTO.fromEntity(session.user).toJson();

    await SecureStorageAdapter.saveDto(_sessionUserKey, userMap);
    await SecureStorageAdapter.writeToken(_accessKey, session.token);
    if (session.refreshToken != null) {
      await SecureStorageAdapter.writeToken(refreshKey, session.refreshToken);
    }
  }

  static Future<AuthResponseDTO?> getSession() async {
    //If we already have the session in memory, we check
    // its validity before returning it
    if (_session != null) {
      final token = _session!.token;
      if (!isJwtExpired(token)) {
        return _session;
      }
      final refreshed = await _tryRefreshUsingStoredRefreshToken();
      return refreshed;
    }

    final userMap = await SecureStorageAdapter.readDto<Map<String, dynamic>>(
      _sessionUserKey,
      (m) => m,
    );
    final access = await SecureStorageAdapter.readToken(_accessKey);
    final refresh = await SecureStorageAdapter.readToken(refreshKey);

    if (userMap == null || access == null) return null;

    final combined = {
      'user': userMap,
      'token': access,
      'refreshToken': refresh,
    };
    final dto = AuthResponseDTO.fromJson(combined);

    //If the token is not expired, return it
    if (!isJwtExpired(access)) {
      _session = dto;
      return dto;
    }

    //Token expired -> try refresh
    return _tryRefreshUsingStoredRefreshToken();
  }

  static Future<void> clearSession() async {
    _session = null;
    await SecureStorageAdapter.delete(_sessionUserKey);
    await SecureStorageAdapter.delete(_accessKey);
    await SecureStorageAdapter.delete(refreshKey);
  }

  static Future<String?> get accessToken async {
    final session = await getSession();
    return session?.token;
  }

  static Future<String?> get refreshToken async {
    final session = await getSession();
    return session?.refreshToken;
  }

  static Future<void> updateAccessToken(String newAccessToken) async {
    final session = await getSession();
    if (session != null) {
      final updated = session.copyWith(token: newAccessToken);
      _session = updated;
      await SecureStorageAdapter.writeToken(_accessKey, newAccessToken);
      final userMap = (updated.user is UserDTO)
          ? (updated.user as UserDTO).toJson()
          : UserDTO.fromEntity(updated.user).toJson();
      await SecureStorageAdapter.saveDto(_sessionUserKey, userMap);
    }
  }

  static Future<bool> hasSession() async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  static Future<void> handleTokenExpired() async {
    //Cleans and notifies via bloc
    await clearSession();
    try {
      sl<SessionBloc>().add(const SessionExpired());
    } catch (_) {}
  }

  static bool isJwtExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final map = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      final exp = map['exp'];
      if (exp == null) return true;
      final expSeconds = (() {
        if (exp is int) return exp;
        if (exp is double) return exp.toInt();
        return int.tryParse(exp.toString());
      })();
      if (expSeconds == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  //Tries to refresh using the refresh token from storage -> updates
  // storage if OK
  static Future<AuthResponseDTO?> _tryRefreshUsingStoredRefreshToken() async {
    final storedRefresh = await SecureStorageAdapter.readToken(refreshKey);
    if (storedRefresh == null) {
      await handleTokenExpired();
      return null;
    }

    try {
      final uri = Uri.parse('http://$apiProject$_refreshPath');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': storedRefresh}),
          )
          .timeout(const Duration(seconds: 6));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final access =
            (decoded['access'] ?? decoded['token'] ?? decoded['access_token'])
                as String?;
        final refresh =
            (decoded['refresh'] ??
                    decoded['refreshToken'] ??
                    decoded['refresh_token'])
                as String?;
        final userMap =
            decoded['user'] as Map<String, dynamic>? ??
            (await SecureStorageAdapter.readDto(_sessionUserKey, (m) => m));
        if (access == null) {
          await handleTokenExpired();
          return null;
        }
        final combined = {
          'user': userMap,
          'token': access,
          'refreshToken': refresh,
        };
        final newDto = AuthResponseDTO.fromJson(combined);
        await saveSession(newDto);
        return newDto;
      } else {
        await handleTokenExpired();
        return null;
      }
    } catch (e) {
      //If the refresh request fails -> we assume we couldn't refresh
      debugPrint('SessionManager _tryRefreshUsingStoredRefreshToken error: $e');
      await handleTokenExpired();
      return null;
    }
  }
}
