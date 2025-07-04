import 'dart:async';

import 'package:indriver_uber_clone/core/bloc/session-bloc/session_bloc.dart';
import 'package:indriver_uber_clone/core/services/injection_container.dart';
import 'package:indriver_uber_clone/core/services/shared_prefs_adapter.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/mappers/auth_response_mapper.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';

class SessionManager {
  static AuthResponseDTO? _session;
  static const _sessionKey = 'user';

  static Future<void> saveSession(AuthResponseDTO session) async {
    _session = session;
    await SharedPrefsAdapter.saveDto(_sessionKey, session.toJson());
  }

  static Future<AuthResponseDTO?> getSession() async {
    _session ??= await SharedPrefsAdapter.readDto<AuthResponseDTO>(
      _sessionKey,
      AuthResponseDTO.fromJson,
    );

    if (_session?.token.isEmpty ?? true) return null;
    return _session;
  }

  static Future<void> clearSession() async {
    _session = null;
    await SharedPrefsAdapter.remove(_sessionKey);
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
      await saveSession(updated.toDto());
    }
  }

  static Future<bool> hasSession() async {
    final session = await getSession();
    return session?.token != null;
  }

  static void handleTokenExpired() {
    clearSession();
    sl<SessionBloc>().add(const SessionExpired());
  }
}
