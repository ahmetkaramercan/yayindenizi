import 'package:flutter/material.dart';

/// String extensions
extension StringExtensions on String {
  /// İlk harfi büyük yapar
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Tüm kelimelerin ilk harfini büyük yapar
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Boş mu kontrolü (trim ile)
  bool get isNullOrEmpty => trim().isEmpty;

  /// Boş değil mi kontrolü
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Tarihi formatlı string'e çevirir
  String toFormattedString({String format = 'dd.MM.yyyy'}) {
    // Basit formatlama - daha gelişmiş için intl paketi kullanılabilir
    final dayStr = this.day.toString().padLeft(2, '0');
    final monthStr = this.month.toString().padLeft(2, '0');
    final yearStr = this.year.toString();
    return format
        .replaceAll('dd', dayStr)
        .replaceAll('MM', monthStr)
        .replaceAll('yyyy', yearStr);
  }
}

/// BuildContext extensions
extension BuildContextExtensions on BuildContext {
  /// Theme'e kolay erişim
  ThemeData get theme => Theme.of(this);

  /// TextTheme'e kolay erişim
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// ColorScheme'e kolay erişim
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// MediaQuery'ye kolay erişim
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Ekran genişliği
  double get screenWidth => mediaQuery.size.width;

  /// Ekran yüksekliği
  double get screenHeight => mediaQuery.size.height;

  /// Show snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

