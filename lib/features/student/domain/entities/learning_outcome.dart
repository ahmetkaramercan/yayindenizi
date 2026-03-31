import 'package:equatable/equatable.dart';

class LearningOutcome extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? videoUrl;

  const LearningOutcome({
    required this.id,
    required this.name,
    this.description,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [id, name, description, videoUrl];

  LearningOutcome copyWith({
    String? id,
    String? name,
    String? description,
    String? videoUrl,
  }) {
    return LearningOutcome(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
