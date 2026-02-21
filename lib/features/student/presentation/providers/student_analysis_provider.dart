import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student_analysis.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/analytics_repository.dart';

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

  final _analyticsRepo = sl<AnalyticsRepository>();

  Future<void> loadAnalysis() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _analyticsRepo.getMyFull();

      final sections = data['sections'] as List? ?? [];
      final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

      for (final section in sections) {
        final s = section as Map<String, dynamic>;
        final outcomes = s['learningOutcomes'] as List? ?? [];

        for (final lo in outcomes) {
          final o = lo as Map<String, dynamic>;
          final id = o['id'] ?? o['learningOutcomeId'] ?? '';
          learningOutcomeProgress[id] = LearningOutcomeProgress(
            learningOutcome: LearningOutcome(
              id: id,
              name: o['name'] ?? '',
              description: o['description'],
            ),
            totalQuestions: o['totalQuestions'] ?? 0,
            completedQuestions: o['completedQuestions'] ?? o['totalQuestions'] ?? 0,
            correctAnswers: o['correctAnswers'] ?? 0,
            completionPercentage: _toDouble(o['completionPercentage'] ?? 0),
            successPercentage: _toDouble(o['successPercentage'] ?? 0),
          );
        }
      }

      final analysis = StudentAnalysis(
        studentId: data['studentId'] ?? '',
        learningOutcomeProgress: learningOutcomeProgress,
        totalTestsCompleted: data['totalTests'] ?? 0,
        overallSuccessPercentage: _toDouble(data['overallSuccess'] ?? 0),
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

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return 0.0;
  }
}

final studentAnalysisProvider =
    StateNotifierProvider<StudentAnalysisNotifier, StudentAnalysisState>(
        (ref) {
  return StudentAnalysisNotifier(ref);
});
