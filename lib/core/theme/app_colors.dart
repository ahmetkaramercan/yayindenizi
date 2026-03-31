import 'package:flutter/material.dart';

/// Uygulama renk paleti
class AppColors {
  AppColors._();

  // Ana renk: Koyu Lacivert
  static const Color primaryDark = Color(0xFF1A237E); // Koyu lacivert
  static const Color primary = Color(0xFF283593);
  static const Color primaryLight = Color(0xFF3949AB);

  // İkincil renk: Beyaz
  static const Color secondary = Color(0xFFFFFFFF);
  static const Color secondaryLight = Color(0xFFF5F5F5);
  static const Color secondaryDark = Color(0xFFE0E0E0);

  // Vurgu rengi: Kırmızı
  static const Color accent = Color(0xFFD32F2F);
  static const Color accentLight = Color(0xFFE53935);
  static const Color accentDark = Color(0xFFB71C1C);
  static const Color accentSurface = Color(0xFFFFF3F3); // Çok açık kırmızı arka plan

  // Metin renkleri
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Durum renkleri
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  // Arka plan renkleri
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFFF5F5F5);

  // Kenarlık renkleri
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color borderDark = Color(0xFFBDBDBD);
}

