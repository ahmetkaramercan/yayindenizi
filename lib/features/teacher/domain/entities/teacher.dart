import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final String? id;
  final String adSoyad;
  final String email;
  final String? sifre;
  final String? cityId;
  final String? districtId;
  final String? cityName;
  final String? districtName;
  final String? okul;
  final String ogretmenKodu; // Unique

  const Teacher({
    this.id,
    required this.adSoyad,
    required this.email,
    this.sifre,
    this.cityId,
    this.districtId,
    this.cityName,
    this.districtName,
    this.okul,
    required this.ogretmenKodu,
  });

  /// Display string for location (e.g. "İstanbul, Kadıköy")
  String? get locationDisplay {
    if (cityName != null && cityName!.isNotEmpty) {
      if (districtName != null && districtName!.isNotEmpty) {
        return '$cityName, $districtName';
      }
      return cityName;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        adSoyad,
        email,
        sifre,
        cityId,
        districtId,
        cityName,
        districtName,
        okul,
        ogretmenKodu,
      ];

  Teacher copyWith({
    String? id,
    String? adSoyad,
    String? email,
    String? sifre,
    String? cityId,
    String? districtId,
    String? cityName,
    String? districtName,
    String? okul,
    String? ogretmenKodu,
  }) {
    return Teacher(
      id: id ?? this.id,
      adSoyad: adSoyad ?? this.adSoyad,
      email: email ?? this.email,
      sifre: sifre ?? this.sifre,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      cityName: cityName ?? this.cityName,
      districtName: districtName ?? this.districtName,
      okul: okul ?? this.okul,
      ogretmenKodu: ogretmenKodu ?? this.ogretmenKodu,
    );
  }
}


