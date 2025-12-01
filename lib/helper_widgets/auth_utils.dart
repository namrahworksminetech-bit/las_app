// lib/core/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:get_it/get_it.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _kTokenKey = 'auth_token';
  static const String _kReqIdKey = 'req_id';
  static const String _kTokenSavedAtKey = 'token_saved_at_ms';
  static const Duration _kTokenExpiry = Duration(minutes: 30);

  /// Persist token + reqId + timestamp
  Future<void> saveAuth({required String token, String? reqId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTokenKey, token);
      if (reqId != null && reqId.isNotEmpty) {
        await prefs.setString(_kReqIdKey, reqId);
      }
      await prefs.setInt(_kTokenSavedAtKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // don't throw — caller should handle non-persistence gracefully
      // but log for debugging
      debugPrint?.call('AuthService.saveAuth: failed to persist auth: $e');
    }
  }

  /// Clear stored auth
  Future<void> clearAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kTokenKey);
      await prefs.remove(_kReqIdKey);
      await prefs.remove(_kTokenSavedAtKey);
    } catch (e) {
      debugPrint?.call('AuthService.clearAuth: $e');
    }
  }

  /// Returns token from prefs (or null)
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kTokenKey);
      final savedAtMs = prefs.getInt(_kTokenSavedAtKey);
      if (token == null || token.isEmpty || savedAtMs == null) return null;

      final savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtMs);
      final age = DateTime.now().difference(savedAt);
      if (age >= _kTokenExpiry) {
        // expired
        await clearAuth();
        return null;
      }
      return token;
    } catch (e) {
      debugPrint?.call('AuthService.getToken: $e');
      return null;
    }
  }

  /// Returns reqId from prefs (or null)
  Future<String?> getReqId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reqId = prefs.getString(_kReqIdKey);
      return (reqId != null && reqId.isNotEmpty) ? reqId : null;
    } catch (e) {
      debugPrint?.call('AuthService.getReqId: $e');
      return null;
    }
  }

  /// Reads token+reqId from prefs, validates token age, and if valid, restores them into AppStateProvider.
  /// Returns true if restore succeeded (token present & valid and reqId present)
  Future<bool> restoreToAppState() async {
    try {
      final token = await getToken();
      final reqId = await getReqId();

      if (token == null || token.isEmpty) return false;
      if (reqId == null || reqId.isEmpty) return false;

      final appState = GetIt.I<AppStateProvider>();
      appState.setToken(token);
      appState.setReqId(reqId);
      return true;
    } catch (e) {
      debugPrint?.call('AuthService.restoreToAppState: $e');
      return false;
    }
  }

  /// Convenience: returns whether there's a valid saved token+reqId
  Future<bool> hasValidAuth() async {
    final token = await getToken();
    final reqId = await getReqId();
    return token != null && reqId != null;
  }
}
