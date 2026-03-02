import 'package:equatable/equatable.dart';

class Classroom extends Equatable {
  final String id;
  final String name;
  final String code;
  final String teacherId;
  final int studentCount;
  final DateTime createdAt;

  const Classroom({
    required this.id,
    required this.name,
    required this.code,
    required this.teacherId,
    required this.studentCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, code, teacherId, studentCount, createdAt];

  Classroom copyWith({
    String? id,
    String? name,
    String? code,
    String? teacherId,
    int? studentCount,
    DateTime? createdAt,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacherId: teacherId ?? this.teacherId,
      studentCount: studentCount ?? this.studentCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
