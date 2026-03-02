import '../../domain/entities/classroom.dart';

class ClassroomModel {
  static Classroom fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    return Classroom(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      teacherId: json['teacherId'] as String? ?? '',
      studentCount: (count?['students'] ?? json['studentCount'] ?? 0) as int,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
