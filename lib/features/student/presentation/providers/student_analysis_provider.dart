import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student_analysis.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../../../core/constants/learning_outcomes.dart';
import '../providers/test_provider.dart';
import '../providers/mock_test_provider.dart';
import '../providers/topic_provider.dart';

class StudentAnalysisState {
  final StudentAnalysis? analysis;
  final bool isLoading;
  final String? error;

  StudentAnalysisState({
    this.analysis,
    this.isLoading = false,
    this.error,
  });

  StudentAnalysisState copyWith({
    StudentAnalysis? analysis,
    bool? isLoading,
    String? error,
  }) {
    return StudentAnalysisState(
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StudentAnalysisNotifier extends StateNotifier<StudentAnalysisState> {
  final Ref ref;

  StudentAnalysisNotifier(this.ref) : super(StudentAnalysisState()) {
    loadAnalysis();
  }

  Future<void> loadAnalysis() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den öğrenci analizini getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş analiz verisi
      // Gerçek uygulamada tüm test sonuçlarından hesaplanacak
      final allOutcomes = AppLearningOutcomes.getAll();
      final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

      for (final outcome in allOutcomes) {
        // Simüle edilmiş veriler
        final totalQuestions = 20; // Bu kazanımdan toplam soru sayısı
        final completedQuestions = (totalQuestions * 0.6).toInt(); // %60 tamamlanmış
        final correctAnswers = (completedQuestions * 0.75).toInt(); // %75 başarı
        final completionPercentage =
            (completedQuestions / totalQuestions) * 100;
        final successPercentage = completedQuestions > 0
            ? (correctAnswers / completedQuestions) * 100
            : 0.0;

        learningOutcomeProgress[outcome.id] = LearningOutcomeProgress(
          learningOutcome: outcome,
          totalQuestions: totalQuestions,
          completedQuestions: completedQuestions,
          correctAnswers: correctAnswers,
          completionPercentage: completionPercentage,
          successPercentage: successPercentage,
        );
      }

      final analysis = StudentAnalysis(
        studentId: 'current_student', // TODO: Gerçek öğrenci ID'si
        learningOutcomeProgress: learningOutcomeProgress,
        totalTestsCompleted: 15, // Simüle edilmiş
        overallSuccessPercentage: 72.5, // Simüle edilmiş
      );

      state = state.copyWith(
        analysis: analysis,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final studentAnalysisProvider =
    StateNotifierProvider<StudentAnalysisNotifier, StudentAnalysisState>(
        (ref) {
  return StudentAnalysisNotifier(ref);
});


