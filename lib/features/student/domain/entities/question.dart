import 'package:equatable/equatable.dart';
import 'learning_outcome.dart';

class Question extends Equatable {
  final String id;
  final String text;
  final List<String> options; // 4 şık
  final int correctAnswerIndex; // 0-3 arası
  final LearningOutcome learningOutcome;
  final String? explanation;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.learningOutcome,
    this.explanation,
  }) : assert(options.length == 4, 'Her soru 4 şıka sahip olmalıdır'),
       assert(correctAnswerIndex >= 0 && correctAnswerIndex < 4, 'Doğru cevap indeksi 0-3 arası olmalıdır');

  @override
  List<Object?> get props => [
        id,
        text,
        options,
        correctAnswerIndex,
        learningOutcome,
        explanation,
      ];

  Question copyWith({
    String? id,
    String? text,
    List<String>? options,
    int? correctAnswerIndex,
    LearningOutcome? learningOutcome,
    String? explanation,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      learningOutcome: learningOutcome ?? this.learningOutcome,
      explanation: explanation ?? this.explanation,
    );
  }
}


