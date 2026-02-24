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
    super.cityId,
    super.districtId,
    super.cityName,
    super.districtName,
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
      cityId: cityId,
      districtId: districtId,
      cityName: cityName,
      districtName: districtName,
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
      cityId: teacher.cityId,
      districtId: teacher.districtId,
      cityName: teacher.cityName,
      districtName: teacher.districtName,
      okul: teacher.okul,
      ogretmenKodu: teacher.ogretmenKodu,
    );
  }
}

