import 'package:equatable/equatable.dart';
import 'learning_outcome.dart';

class TopicAnswerResult extends Equatable {
  final String questionId;
  final int? selectedAnswerIndex;
  final bool isCorrect;
  final int correctAnswerIndex;

  const TopicAnswerResult({
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

class TopicTestResult extends Equatable {
  final String testId;
  final String testTitle;
  final String topicId;
  final String topicTitle;
  final List<TopicAnswerResult> answers;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double successPercentage;
  final DateTime completedAt;
  final Map<String, TopicLearningOutcomeStats> learningOutcomeStats;

  const TopicTestResult({
    required this.testId,
    required this.testTitle,
    required this.topicId,
    required this.topicTitle,
    required this.answers,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.successPercentage,
    required this.completedAt,
    required this.learningOutcomeStats,
  });

  @override
  List<Object?> get props => [
        testId,
        testTitle,
        topicId,
        topicTitle,
        answers,
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        successPercentage,
        completedAt,
        learningOutcomeStats,
      ];
}

class TopicLearningOutcomeStats extends Equatable {
  final LearningOutcome learningOutcome;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double successPercentage;

  const TopicLearningOutcomeStats({
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


