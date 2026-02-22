import 'package:equatable/equatable.dart';
import 'learning_outcome.dart';

class LearningOutcomeProgress extends Equatable {
  final LearningOutcome learningOutcome;
  final int totalQuestions; // Bu kazanımdan toplam soru sayısı
  final int completedQuestions; // Çözülen soru sayısı
  final int correctAnswers; // Doğru cevap sayısı
  final int incorrectAnswers; // Yanlış cevap sayısı
  final double completionPercentage; // Tamamlanma yüzdesi
  final double successPercentage; // Başarı yüzdesi

  const LearningOutcomeProgress({
    required this.learningOutcome,
    required this.totalQuestions,
    required this.completedQuestions,
    required this.correctAnswers,
    this.incorrectAnswers = 0,
    required this.completionPercentage,
    required this.successPercentage,
  });

  @override
  List<Object?> get props => [
        learningOutcome,
        totalQuestions,
        completedQuestions,
        correctAnswers,
        incorrectAnswers,
        completionPercentage,
        successPercentage,
      ];
}

class StudentAnalysis extends Equatable {
  final String studentId;
  final Map<String, LearningOutcomeProgress> learningOutcomeProgress;
  final int totalTestsCompleted;
  final double overallSuccessPercentage;
  final int totalCorrect;
  final int totalIncorrect;

  const StudentAnalysis({
    required this.studentId,
    required this.learningOutcomeProgress,
    required this.totalTestsCompleted,
    required this.overallSuccessPercentage,
    this.totalCorrect = 0,
    this.totalIncorrect = 0,
  });

  @override
  List<Object?> get props => [
        studentId,
        learningOutcomeProgress,
        totalTestsCompleted,
        overallSuccessPercentage,
        totalCorrect,
        totalIncorrect,
      ];
}


