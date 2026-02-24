import 'package:equatable/equatable.dart';
import 'learning_outcome.dart';

enum AnswerStatus {
  correct,
  wrong,
  empty,
}

class MockAnswerResult extends Equatable {
  final String questionId;
  final int? selectedAnswerIndex;
  final AnswerStatus status;
  final int correctAnswerIndex;

  const MockAnswerResult({
    required this.questionId,
    this.selectedAnswerIndex,
    required this.status,
    required this.correctAnswerIndex,
  });

  @override
  List<Object?> get props => [
        questionId,
        selectedAnswerIndex,
        status,
        correctAnswerIndex,
      ];
}

class MockTestResult extends Equatable {
  final String testId;
  final String testTitle;
  final List<MockAnswerResult> answers;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final double successPercentage;
  final Duration? duration; // İleride kullanılacak
  final DateTime completedAt;
  final Map<String, int> learningOutcomeStats; // Kazanım ID -> Doğru sayısı (deprecated, use learningOutcomeStatsList)
  final List<MockLearningOutcomeStats> learningOutcomeStatsList; // Test analizi için

  const MockTestResult({
    required this.testId,
    required this.testTitle,
    required this.answers,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
    required this.successPercentage,
    this.duration,
    required this.completedAt,
    required this.learningOutcomeStats,
    this.learningOutcomeStatsList = const [],
  });

  @override
  List<Object?> get props => [
        testId,
        testTitle,
        answers,
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        emptyAnswers,
        successPercentage,
        duration,
        completedAt,
        learningOutcomeStats,
        learningOutcomeStatsList,
      ];
}

class MockLearningOutcomeStats extends Equatable {
  final LearningOutcome learningOutcome;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double successPercentage;

  const MockLearningOutcomeStats({
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

class MockTestAnalysis {
  final List<MockTestResult> recentResults;
  final int totalTests;
  final double averageSuccessPercentage;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final int totalEmptyAnswers;
  final Map<String, AnalysisLearningOutcomeStats> learningOutcomeStats;

  const MockTestAnalysis({
    required this.recentResults,
    required this.totalTests,
    required this.averageSuccessPercentage,
    required this.totalCorrectAnswers,
    required this.totalWrongAnswers,
    required this.totalEmptyAnswers,
    required this.learningOutcomeStats,
  });
}

class AnalysisLearningOutcomeStats {
  final LearningOutcome learningOutcome;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final double successPercentage;

  const AnalysisLearningOutcomeStats({
    required this.learningOutcome,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
    required this.successPercentage,
  });
}


