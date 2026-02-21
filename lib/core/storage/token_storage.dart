import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';

  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    await _prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<void> saveUser({
    required String id,
    required String role,
    required String name,
    required String email,
  }) async {
    await _prefs.setString(_keyUserId, id);
    await _prefs.setString(_keyUserRole, role);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserEmail, email);
  }

  String? get accessToken => _prefs.getString(_keyAccessToken);
  String? get refreshToken => _prefs.getString(_keyRefreshToken);
  String? get userId => _prefs.getString(_keyUserId);
  String? get userRole => _prefs.getString(_keyUserRole);
  String? get userName => _prefs.getString(_keyUserName);
  String? get userEmail => _prefs.getString(_keyUserEmail);

  bool get isLoggedIn => accessToken != null;

  Future<void> clear() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
  }
}
