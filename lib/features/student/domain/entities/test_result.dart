import 'package:equatable/equatable.dart';
import 'question.dart';
import 'learning_outcome.dart';

class AnswerResult extends Equatable {
  final String questionId;
  final int? selectedAnswerIndex;
  final bool isCorrect;
  final int correctAnswerIndex;

  const AnswerResult({
    required this.questionId,
    this.selectedAnswerIndex,
    required this.isCorrect,
    required this.correctAnswerIndex,
  });

  @override
  List<Object?> get props => [
        questionId,
        selectedAnswerIndex,
        isCorrect,
        correctAnswerIndex,
      ];
}

class LearningOutcomeStats extends Equatable {
  final LearningOutcome learningOutcome;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double successPercentage;

  const LearningOutcomeStats({
    required this.learningOutcome,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.successPercentage,
  });

  @override
  List<Object?> get props => [
        learningOutcome,
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        successPercentage,
      ];
}

class TestResult extends Equatable {
  final String testId;
  final int level;
  final List<AnswerResult> answers;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double successPercentage;
  final List<LearningOutcomeStats> learningOutcomeStats;
  final Duration? duration;

  const TestResult({
    required this.testId,
    required this.level,
    required this.answers,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.successPercentage,
    required this.learningOutcomeStats,
    this.duration,
  });

  @override
  List<Object?> get props => [
        testId,
        level,
        answers,
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        successPercentage,
        learningOutcomeStats,
        duration,
      ];
}


