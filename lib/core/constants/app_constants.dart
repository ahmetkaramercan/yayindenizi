class AppConstants {
  AppConstants._();

  // Uygulama bilgileri
  static const String appName = 'Yayın Denizi';
  static const String appVersion = '1.0.0';

  // Kullanıcı tipleri
  static const String userTypeStudent = 'student';
  static const String userTypeTeacher = 'teacher';

  // Production (Fly.io)
  static const String baseUrl = 'https://yayindenizi-backend.fly.dev/api/v1';
  // Geliştirme - iOS Simulator
  // static const String baseUrl = 'http://localhost:3000/api/v1';
  // Geliştirme - Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // Timeout süreleri
  static const int connectTimeout = 30000; // 30 saniye
  static const int receiveTimeout = 30000; // 30 saniye

  // Local Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserType = 'user_type';
  static const String keyUserId = 'user_id';
  static const String keyIsLoggedIn = 'is_logged_in';

  // Sayfa limitleri
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animasyon süreleri
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Padding değerleri
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius değerleri
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 999.0;
}

