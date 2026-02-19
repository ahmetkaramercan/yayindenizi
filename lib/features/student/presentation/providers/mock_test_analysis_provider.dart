import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mock_test_result.dart';
import '../../domain/entities/learning_outcome.dart';
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

  Future<void> loadAnalysis() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den analiz verilerini getir
      await Future.delayed(const Duration(seconds: 1));

      // Kaydedilmiş sonuçları al
      final mockTestNotifier = ref.read(mockTestProvider.notifier);
      final savedResults = mockTestNotifier.getSavedResults();

      if (savedResults.isEmpty) {
        state = state.copyWith(
          analysis: null,
          isLoading: false,
        );
        return;
      }

      // Son X test (örneğin son 10 test)
      final recentResults = savedResults.take(10).toList();

      // Genel istatistikleri hesapla
      final totalTests = recentResults.length;
      final totalCorrectAnswers =
          recentResults.fold(0, (sum, r) => sum + r.correctAnswers);
      final totalWrongAnswers =
          recentResults.fold(0, (sum, r) => sum + r.wrongAnswers);
      final totalEmptyAnswers =
          recentResults.fold(0, (sum, r) => sum + r.emptyAnswers);
      final averageSuccessPercentage = recentResults.isEmpty
          ? 0.0
          : recentResults.fold(0.0, (sum, r) => sum + r.successPercentage) /
              recentResults.length;

      // Kazanım bazlı istatistikleri hesapla
      final learningOutcomeMap = <String, Map<String, int>>{};

      for (final result in recentResults) {
        for (final entry in result.learningOutcomeStats.entries) {
          final outcomeId = entry.key;
          final correctCount = entry.value;

          if (!learningOutcomeMap.containsKey(outcomeId)) {
            learningOutcomeMap[outcomeId] = {
              'total': 0,
              'correct': 0,
              'wrong': 0,
              'empty': 0,
            };
          }

          // Bu kazanımdan kaç soru var?
          // Sonuçlardan kazanım bazlı soru sayısını bulmak için
          // Her test için kazanım bazlı soru sayısını hesaplamamız gerekir
          // Şimdilik basit bir yaklaşım kullanıyoruz
        }
      }

      // Tüm sonuçlardan kazanım bazlı istatistikleri hesapla
      final learningOutcomeStats = <String, AnalysisLearningOutcomeStats>{};

      // Her kazanım için istatistikleri topla
      final allOutcomes = _getAllLearningOutcomes();
      for (final outcome in allOutcomes) {
        int totalQuestions = 0;
        int correctAnswers = 0;
        int wrongAnswers = 0;
        int emptyAnswers = 0;

        for (final result in recentResults) {
          for (final answer in result.answers) {
            // Bu sorunun kazanımını bulmak için test verilerine ihtiyacımız var
            // Şimdilik basit bir yaklaşım kullanıyoruz
            // Gerçek uygulamada bu bilgi result'ta saklanmalı
          }
        }

        if (totalQuestions > 0) {
          final successPercentage = (correctAnswers / totalQuestions) * 100;
          learningOutcomeStats[outcome.id] = AnalysisLearningOutcomeStats(
            learningOutcome: outcome,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            emptyAnswers: emptyAnswers,
            successPercentage: successPercentage,
          );
        }
      }

      final analysis = MockTestAnalysis(
        recentResults: recentResults,
        totalTests: totalTests,
        averageSuccessPercentage: averageSuccessPercentage,
        totalCorrectAnswers: totalCorrectAnswers,
        totalWrongAnswers: totalWrongAnswers,
        totalEmptyAnswers: totalEmptyAnswers,
        learningOutcomeStats: learningOutcomeStats,
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

  List<LearningOutcome> _getAllLearningOutcomes() {
    return [
      const LearningOutcome(
        id: 'lo_1',
        name: 'Ana Düşünce',
        description: 'Paragrafın ana düşüncesini belirleme',
      ),
      const LearningOutcome(
        id: 'lo_2',
        name: 'Yardımcı Düşünce',
        description: 'Yardımcı düşünceleri ayırt etme',
      ),
      const LearningOutcome(
        id: 'lo_3',
        name: 'Anlam İlişkisi',
        description: 'Cümleler arası anlam ilişkilerini kavrama',
      ),
      const LearningOutcome(
        id: 'lo_4',
        name: 'Anlatım Teknikleri',
        description: 'Anlatım tekniklerini tanıma',
      ),
      const LearningOutcome(
        id: 'lo_5',
        name: 'Dil Bilgisi',
        description: 'Dil bilgisi kurallarını uygulama',
      ),
    ];
  }
}

final mockTestAnalysisProvider =
    StateNotifierProvider<MockTestAnalysisNotifier, MockTestAnalysisState>(
        (ref) {
  return MockTestAnalysisNotifier(ref);
});


