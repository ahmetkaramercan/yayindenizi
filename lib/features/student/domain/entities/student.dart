import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String? id;
  final String adSoyad;
  final String email;
  final String? sifre;
  final String? il;
  final String? ilce;
  final List<String> bagliOgretmenler; // Öğretmen ID'leri

  const Student({
    this.id,
    required this.adSoyad,
    required this.email,
    this.sifre,
    this.il,
    this.ilce,
    this.bagliOgretmenler = const [],
  });

  @override
  List<Object?> get props => [
        id,
        adSoyad,
        email,
        sifre,
        il,
        ilce,
        bagliOgretmenler,
      ];

  Student copyWith({
    String? id,
    String? adSoyad,
    String? email,
    String? sifre,
    String? il,
    String? ilce,
    List<String>? bagliOgretmenler,
  }) {
    return Student(
      id: id ?? this.id,
      adSoyad: adSoyad ?? this.adSoyad,
      email: email ?? this.email,
      sifre: sifre ?? this.sifre,
      il: il ?? this.il,
      ilce: ilce ?? this.ilce,
      bagliOgretmenler: bagliOgretmenler ?? this.bagliOgretmenler,
    );
  }
}


