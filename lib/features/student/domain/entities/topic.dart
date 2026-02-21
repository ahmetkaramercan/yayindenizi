import 'package:equatable/equatable.dart';
import 'learning_outcome.dart';

class Topic extends Equatable {
  final String id;
  final String title;
  final String? description;
  final List<LearningOutcome> learningOutcomes; // Bu konuya ait kazanımlar
  final int? testCount; // Bu konuya ait test sayısı

  const Topic({
    required this.id,
    required this.title,
    this.description,
    this.learningOutcomes = const [],
    this.testCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        learningOutcomes,
        testCount,
      ];

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    List<LearningOutcome>? learningOutcomes,
    int? testCount,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      learningOutcomes: learningOutcomes ?? this.learningOutcomes,
      testCount: testCount ?? this.testCount,
    );
  }
}


