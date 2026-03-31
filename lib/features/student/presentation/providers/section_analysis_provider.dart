import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student_analysis.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/analytics_repository.dart';

class SectionAnalysisState {
  final StudentAnalysis? analysis;
  final String? sectionTitle;
  final String? bookTitle;
  final bool isLoading;
  final String? error;

  SectionAnalysisState({
    this.analysis,
    this.sectionTitle,
    this.bookTitle,
    this.isLoading = false,
    this.error,
  });

  SectionAnalysisState copyWith({
    StudentAnalysis? analysis,
    String? sectionTitle,
    String? bookTitle,
    bool? isLoading,
    String? error,
  }) {
    return SectionAnalysisState(
      analysis: analysis ?? this.analysis,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      bookTitle: bookTitle ?? this.bookTitle,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SectionAnalysisNotifier extends StateNotifier<SectionAnalysisState> {
  final String sectionId;
  final Ref _ref;
  final _analyticsRepo = sl<AnalyticsRepository>();

  SectionAnalysisNotifier(this.sectionId, this._ref) : super(SectionAnalysisState()) {
    _ref.keepAlive();
    loadAnalysis();
  }

  Future<void> loadAnalysis() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _analyticsRepo.getMySectionAnalysis(sectionId);

      final rawOutcomes = data['learningOutcomes'] as List? ?? [];
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
            videoUrl: o['videoUrl']?.toString(),
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

      final analysis = StudentAnalysis(
        studentId: data['studentId'] ?? '',
        learningOutcomeProgress: learningOutcomeProgress,
        totalTestsCompleted: (data['totalTests'] ?? 0) as int,
        overallSuccessPercentage: _toDouble(data['overallSuccess'] ?? 0),
        totalCorrect: (data['totalCorrect'] ?? 0) as int,
        totalIncorrect: (data['totalIncorrect'] ?? 0) as int,
      );

      state = state.copyWith(
        analysis: analysis,
        sectionTitle: data['sectionTitle'] as String?,
        bookTitle: data['bookTitle'] as String?,
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

final sectionAnalysisProvider =
    StateNotifierProvider.family<SectionAnalysisNotifier, SectionAnalysisState, String>(
        (ref, sectionId) {
  return SectionAnalysisNotifier(sectionId, ref);
});
