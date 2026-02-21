import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mock_test_result.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/analytics_repository.dart';
import 'mock_test_provider.dart';

class MockTestAnalysisState {
  final MockTestAnalysis? analysis;
  final bool isLoading;
  final String? error;

  MockTestAnalysisState({
    this.analysis,
    this.isLoading = false,
    this.error,
  });

  MockTestAnalysisState copyWith({
    MockTestAnalysis? analysis,
    bool? isLoading,
    String? error,
  }) {
    return MockTestAnalysisState(
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MockTestAnalysisNotifier
    extends StateNotifier<MockTestAnalysisState> {
  final Ref ref;

  MockTestAnalysisNotifier(this.ref) : super(MockTestAnalysisState()) {
    loadAnalysis();
  }

  final _analyticsRepo = sl<AnalyticsRepository>();

  Future<void> loadAnalysis() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _analyticsRepo.getMyOverview();

      final mockTestNotifier = ref.read(mockTestProvider.notifier);
      final savedResults = mockTestNotifier.getSavedResults();
      final recentResults = savedResults.take(10).toList();

      final totalTests = (data['totalTests'] ?? recentResults.length) as int;
      final averageSuccess = (data['overallSuccess'] ?? 0.0) is int
          ? (data['overallSuccess'] as int).toDouble()
          : (data['overallSuccess'] ?? 0.0) as double;

      final analysis = MockTestAnalysis(
        recentResults: recentResults,
        totalTests: totalTests,
        averageSuccessPercentage: averageSuccess,
        totalCorrectAnswers:
            recentResults.fold(0, (sum, r) => sum + r.correctAnswers),
        totalWrongAnswers:
            recentResults.fold(0, (sum, r) => sum + r.wrongAnswers),
        totalEmptyAnswers:
            recentResults.fold(0, (sum, r) => sum + r.emptyAnswers),
        learningOutcomeStats: const {},
      );

      state = state.copyWith(
        analysis: analysis,
        isLoading: false,
      );
    } catch (e) {
      // Fallback to local results if API fails
      final mockTestNotifier = ref.read(mockTestProvider.notifier);
      final savedResults = mockTestNotifier.getSavedResults();

      if (savedResults.isNotEmpty) {
        final recentResults = savedResults.take(10).toList();
        final analysis = MockTestAnalysis(
          recentResults: recentResults,
          totalTests: recentResults.length,
          averageSuccessPercentage: recentResults.isEmpty
              ? 0.0
              : recentResults.fold(
                      0.0, (sum, r) => sum + r.successPercentage) /
                  recentResults.length,
          totalCorrectAnswers:
              recentResults.fold(0, (sum, r) => sum + r.correctAnswers),
          totalWrongAnswers:
              recentResults.fold(0, (sum, r) => sum + r.wrongAnswers),
          totalEmptyAnswers:
              recentResults.fold(0, (sum, r) => sum + r.emptyAnswers),
          learningOutcomeStats: const {},
        );
        state = state.copyWith(analysis: analysis, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }
}

final mockTestAnalysisProvider =
    StateNotifierProvider<MockTestAnalysisNotifier, MockTestAnalysisState>(
        (ref) {
  return MockTestAnalysisNotifier(ref);
});
