class Validators {
  Validators._();

  /// Email validasyonu
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gereklidir';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email adresi giriniz';
    }
    return null;
  }

  /// Şifre validasyonu
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  /// Boş alan kontrolü
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} gereklidir';
    }
    return null;
  }

  /// Minimum uzunluk kontrolü
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'Bu alan'} en az $minLength karakter olmalıdır';
    }
    return null;
  }

  /// Maksimum uzunluk kontrolü
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Bu alan'} en fazla $maxLength karakter olabilir';
    }
    return null;
  }

  /// Telefon numarası validasyonu
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gereklidir';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-()]'), ''))) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }

  /// İki şifrenin eşleşmesi kontrolü
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }
}

