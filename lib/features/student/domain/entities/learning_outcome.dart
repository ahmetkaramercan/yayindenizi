import 'package:equatable/equatable.dart';

class LearningOutcome extends Equatable {
  final String id;
  final String name;
  final String? description;

  const LearningOutcome({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];

  LearningOutcome copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return LearningOutcome(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}


