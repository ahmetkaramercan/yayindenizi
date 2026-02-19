import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../student/domain/entities/student_analysis.dart';
import '../../../student/domain/entities/learning_outcome.dart';
import '../../../../core/constants/learning_outcomes.dart';

class TeacherStudentAnalysisState {
  final StudentAnalysis? analysis;
  final bool isLoading;
  final String? error;

  TeacherStudentAnalysisState({
    this.analysis,
    this.isLoading = false,
    this.error,
  });

  TeacherStudentAnalysisState copyWith({
    StudentAnalysis? analysis,
    bool? isLoading,
    String? error,
  }) {
    return TeacherStudentAnalysisState(
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TeacherStudentAnalysisNotifier
    extends StateNotifier<TeacherStudentAnalysisState> {
  TeacherStudentAnalysisNotifier() : super(TeacherStudentAnalysisState());

  Future<void> loadStudentAnalysis(String studentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den öğrenci analizini getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş analiz verisi
      final allOutcomes = AppLearningOutcomes.getAll();
      final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

      for (final outcome in allOutcomes) {
        // Simüle edilmiş veriler
        final totalQuestions = 20;
        final completedQuestions = (totalQuestions * 0.6).toInt();
        final correctAnswers = (completedQuestions * 0.75).toInt();
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
        studentId: studentId,
        learningOutcomeProgress: learningOutcomeProgress,
        totalTestsCompleted: 15,
        overallSuccessPercentage: 72.5,
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

final teacherStudentAnalysisProvider =
    StateNotifierProvider<TeacherStudentAnalysisNotifier,
        TeacherStudentAnalysisState>((ref) {
  return TeacherStudentAnalysisNotifier();
});


