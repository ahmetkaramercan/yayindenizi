import 'dart:math';

class TeacherCodeGenerator {
  TeacherCodeGenerator._();

  /// Benzersiz öğretmen kodu oluşturur
  /// Format: TCH + 6 haneli rastgele sayı
  /// Örnek: TCH123456
  static String generate() {
    final random = Random();
    final code = random.nextInt(900000) + 100000; // 100000-999999 arası
    return 'TCH$code';
  }

  /// Öğretmen kodunun geçerli formatını kontrol eder
  static bool isValid(String code) {
    if (code.length != 9) return false;
    if (!code.startsWith('TCH')) return false;
    final numberPart = code.substring(3);
    return int.tryParse(numberPart) != null;
  }

  /// Öğretmen kodunu formatlar (büyük harfe çevirir)
  static String format(String code) {
    return code.toUpperCase().trim();
  }
}


