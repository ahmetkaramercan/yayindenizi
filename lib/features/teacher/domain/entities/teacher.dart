import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final String? id;
  final String adSoyad;
  final String email;
  final String? sifre;
  final String? il;
  final String? ilce;
  final String? okul;
  final String ogretmenKodu; // Unique

  const Teacher({
    this.id,
    required this.adSoyad,
    required this.email,
    this.sifre,
    this.il,
    this.ilce,
    this.okul,
    required this.ogretmenKodu,
  });

  @override
  List<Object?> get props => [
        id,
        adSoyad,
        email,
        sifre,
        il,
        ilce,
        okul,
        ogretmenKodu,
      ];

  Teacher copyWith({
    String? id,
    String? adSoyad,
    String? email,
    String? sifre,
    String? il,
    String? ilce,
    String? okul,
    String? ogretmenKodu,
  }) {
    return Teacher(
      id: id ?? this.id,
      adSoyad: adSoyad ?? this.adSoyad,
      email: email ?? this.email,
      sifre: sifre ?? this.sifre,
      il: il ?? this.il,
      ilce: ilce ?? this.ilce,
      okul: okul ?? this.okul,
      ogretmenKodu: ogretmenKodu ?? this.ogretmenKodu,
    );
  }
}


