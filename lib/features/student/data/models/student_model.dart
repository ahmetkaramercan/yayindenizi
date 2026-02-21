import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/student.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentModel extends Student {
  const StudentModel({
    @JsonKey(name: '_id') super.id,
    @JsonKey(name: 'ad_soyad') required super.adSoyad,
    required super.email,
    super.sifre,
    super.il,
    super.ilce,
    @JsonKey(name: 'bagli_ogretmenler', defaultValue: []) super.bagliOgretmenler,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  // Entity'ye dönüştürme
  Student toEntity() {
    return Student(
      id: id,
      adSoyad: adSoyad,
      email: email,
      sifre: sifre,
      il: il,
      ilce: ilce,
      bagliOgretmenler: bagliOgretmenler,
    );
  }

  // Entity'den model oluşturma
  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      adSoyad: student.adSoyad,
      email: student.email,
      sifre: student.sifre,
      il: student.il,
      ilce: student.ilce,
      bagliOgretmenler: student.bagliOgretmenler,
    );
  }
}

