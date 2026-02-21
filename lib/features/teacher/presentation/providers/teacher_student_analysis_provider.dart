import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../student/domain/entities/student_analysis.dart';
import '../../../student/domain/entities/learning_outcome.dart';
import '../../../../core/di/injection_container.dart';
import '../../../student/data/repositories/analytics_repository.dart';

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

  final _analyticsRepo = sl<AnalyticsRepository>();

  Future<void> loadStudentAnalysis(String studentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _analyticsRepo.getStudentFull(studentId);

      final sections = data['sections'] as List? ?? [];
      final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

      for (final section in sections) {
        final s = section as Map<String, dynamic>;
        final outcomes = s['learningOutcomes'] as List? ?? [];

        for (final lo in outcomes) {
          final o = lo as Map<String, dynamic>;
          final id = o['id'] ?? '';
          learningOutcomeProgress[id] = LearningOutcomeProgress(
            learningOutcome: LearningOutcome(
              id: id,
              name: o['name'] ?? '',
              description: o['description'],
            ),
            totalQuestions: o['totalQuestions'] ?? 0,
            completedQuestions: o['completedQuestions'] ?? 0,
            correctAnswers: o['correctAnswers'] ?? 0,
            completionPercentage: _toDouble(o['completionPercentage']),
            successPercentage: _toDouble(o['successPercentage']),
          );
        }
      }

      final analysis = StudentAnalysis(
        studentId: studentId,
        learningOutcomeProgress: learningOutcomeProgress,
        totalTestsCompleted: data['totalTests'] ?? 0,
        overallSuccessPercentage: _toDouble(data['overallSuccess']),
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

final teacherStudentAnalysisProvider =
    StateNotifierProvider<TeacherStudentAnalysisNotifier,
        TeacherStudentAnalysisState>((ref) {
  return TeacherStudentAnalysisNotifier();
});
