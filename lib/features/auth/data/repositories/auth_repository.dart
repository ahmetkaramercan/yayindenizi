import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String role;
  final String adSoyad;
  final String? ogretmenKodu;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.role,
    required this.adSoyad,
    this.ogretmenKodu,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userId: user['id'],
      email: user['email'],
      role: user['role'],
      adSoyad: user['adSoyad'],
      ogretmenKodu: user['ogretmenKodu'],
    );
  }
}

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await _persistAuth(response);
    return response;
  }

  Future<AuthResponse> registerStudent({
    required String email,
    required String password,
    required String adSoyad,
    required String cityId,
    required String districtId,
  }) async {
    final data = await _api.post('/auth/register/student', data: {
      'email': email,
      'password': password,
      'adSoyad': adSoyad,
      'cityId': cityId,
      'districtId': districtId,
    });
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await _persistAuth(response);
    return response;
  }

  Future<AuthResponse> registerTeacher({
    required String email,
    required String password,
    required String adSoyad,
    required String cityId,
    required String districtId,
    required String okul,
  }) async {
    final data = await _api.post('/auth/register/teacher', data: {
      'email': email,
      'password': password,
      'adSoyad': adSoyad,
      'cityId': cityId,
      'districtId': districtId,
      'okul': okul,
    });
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await _persistAuth(response);
    return response;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final data = await _api.get('/auth/profile');
    return data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      await _storage.clear();
    }
  }

  /// Extracts a user-friendly error message from a DioException
  static String extractError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'];
        if (msg is List) return msg.join(', ');
        if (msg is String) return msg;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.';
      }
    }
    return e.toString();
  }

  bool get isLoggedIn => _storage.isLoggedIn;
  String? get userRole => _storage.userRole;
  String? get userName => _storage.userName;

  Future<void> _persistAuth(AuthResponse response) async {
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _storage.saveUser(
      id: response.userId,
      role: response.role,
      name: response.adSoyad,
      email: response.email,
    );
  }
}
