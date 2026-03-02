import '../../domain/entities/teacher.dart';

class TeacherModel {
  static Teacher fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>?;
    final district = json['district'] as Map<String, dynamic>?;
    return Teacher(
      id: json['id'] as String?,
      adSoyad: json['adSoyad'] as String? ?? '',
      email: json['email'] as String? ?? '',
      okul: json['okul'] as String?,
      cityId: json['cityId'] as String?,
      districtId: json['districtId'] as String?,
      cityName: city?['name'] as String?,
      districtName: district?['name'] as String?,
    );
  }
}
