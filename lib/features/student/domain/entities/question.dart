import 'package:equatable/equatable.dart';
import 'learning_outcome.dart';

class Question extends Equatable {
  final String id;
  final String text;
  final List<String> options; // 5 şık: A, B, C, D, E
  final int correctAnswerIndex; // 0-4
  final LearningOutcome? learningOutcome;
  final String? explanation;
  final String? videoUrl;

  const Question({
    required this.id,
    this.text = '',
    required this.options,
    required this.correctAnswerIndex,
    this.learningOutcome,
    this.explanation,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        options,
        correctAnswerIndex,
        learningOutcome,
        explanation,
        videoUrl,
      ];

  Question copyWith({
    String? id,
    String? text,
    List<String>? options,
    int? correctAnswerIndex,
    LearningOutcome? learningOutcome,
    String? explanation,
    String? videoUrl,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      learningOutcome: learningOutcome ?? this.learningOutcome,
      explanation: explanation ?? this.explanation,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
