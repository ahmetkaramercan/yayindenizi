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

      final rawOutcomes =
          data['learningOutcomes'] as List? ?? data['learningOutcomeStats'] as List? ?? [];
      final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

      for (final lo in rawOutcomes) {
        final o = lo as Map<String, dynamic>;
        final id = o['id'] ?? o['learningOutcomeId'] ?? '';
        if (id.isEmpty) continue;

        learningOutcomeProgress[id] = LearningOutcomeProgress(
          learningOutcome: LearningOutcome(
            id: id,
            name: o['name'] ?? o['learningOutcomeName'] ?? '',
            description: o['description']?.toString(),
          ),
          totalQuestions: (o['totalQuestions'] ?? 0) as int,
          completedQuestions:
              (o['completedQuestions'] ?? o['totalQuestions'] ?? 0) as int,
          correctAnswers: (o['correctAnswers'] ?? 0) as int,
          incorrectAnswers: (o['incorrectAnswers'] ?? 0) as int,
          completionPercentage: _toDouble(o['completionPercentage'] ?? 100),
          successPercentage:
              _toDouble(o['successPercentage'] ?? o['accuracy'] ?? 0),
        );
      }

      final overview = data['overview'] as Map<String, dynamic>?;
      final totalTests = data['totalTests'] ?? overview?['totalTests'] ?? 0;
      final overallSuccess =
          data['overallSuccess'] ?? overview?['overallAccuracy'] ?? 0;
      final totalCorrect =
          data['totalCorrect'] ?? overview?['totalCorrect'] ?? 0;
      final totalIncorrect =
          data['totalIncorrect'] ?? overview?['totalIncorrect'] ?? 0;

      final analysis = StudentAnalysis(
        studentId: studentId,
        learningOutcomeProgress: learningOutcomeProgress,
        totalTestsCompleted: totalTests as int,
        overallSuccessPercentage: _toDouble(overallSuccess),
        totalCorrect: totalCorrect as int,
        totalIncorrect: totalIncorrect as int,
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
