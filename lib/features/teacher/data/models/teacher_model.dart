import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/teacher.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class TeacherModel extends Teacher {
  const TeacherModel({
    @JsonKey(name: '_id') super.id,
    @JsonKey(name: 'ad_soyad') required super.adSoyad,
    required super.email,
    super.sifre,
    super.il,
    super.ilce,
    super.okul,
    @JsonKey(name: 'ogretmen_kodu') required super.ogretmenKodu,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModelToJson(this);

  // Entity'ye dönüştürme
  Teacher toEntity() {
    return Teacher(
      id: id,
      adSoyad: adSoyad,
      email: email,
      sifre: sifre,
      il: il,
      ilce: ilce,
      okul: okul,
      ogretmenKodu: ogretmenKodu,
    );
  }

  // Entity'den model oluşturma
  factory TeacherModel.fromEntity(Teacher teacher) {
    return TeacherModel(
      id: teacher.id,
      adSoyad: teacher.adSoyad,
      email: teacher.email,
      sifre: teacher.sifre,
      il: teacher.il,
      ilce: teacher.ilce,
      okul: teacher.okul,
      ogretmenKodu: teacher.ogretmenKodu,
    );
  }
}

