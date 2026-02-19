import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mock_test.dart';
import '../../domain/entities/mock_test_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../../../core/constants/learning_outcomes.dart';

class MockTestState {
  final List<MockTest> tests;
  final MockTest? currentTest;
  final MockTestResult? currentResult;
  final bool isLoading;
  final String? error;

  MockTestState({
    this.tests = const [],
    this.currentTest,
    this.currentResult,
    this.isLoading = false,
    this.error,
  });

  MockTestState copyWith({
    List<MockTest>? tests,
    MockTest? currentTest,
    MockTestResult? currentResult,
    bool? isLoading,
    String? error,
  }) {
    return MockTestState(
      tests: tests ?? this.tests,
      currentTest: currentTest,
      currentResult: currentResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MockTestNotifier extends StateNotifier<MockTestState> {
  MockTestNotifier() : super(MockTestState()) {
    loadTests();
  }

  Future<void> loadTests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den test listesini getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş test listesi
      final tests = List.generate(5, (index) {
        final learningOutcomes = _generateLearningOutcomes();
        final questions = _generateQuestions(learningOutcomes, 20); // 20 soru

        return MockTest(
          id: 'mock_test_${index + 1}',
          title: 'Deneme Testi ${index + 1}',
          description: 'Karışık kazanımlardan oluşan deneme testi',
          questions: questions,
          createdAt: DateTime.now().subtract(Duration(days: index)),
        );
      });

      state = state.copyWith(
        tests: tests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTest(String testId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den test detayını getir
      await Future.delayed(const Duration(milliseconds: 500));

      final test = state.tests.firstWhere(
        (t) => t.id == testId,
        orElse: () => state.tests.first,
      );

      state = state.copyWith(
        currentTest: test,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void finishTest(Map<String, int?> answers) {
    final test = state.currentTest;
    if (test == null) return;

    // Cevapları işle
    final answerResults = test.questions.map((question) {
      final selectedAnswer = answers[question.id];
      AnswerStatus status;

      if (selectedAnswer == null) {
        status = AnswerStatus.empty;
      } else if (selectedAnswer == question.correctAnswerIndex) {
        status = AnswerStatus.correct;
      } else {
        status = AnswerStatus.wrong;
      }

      return MockAnswerResult(
        questionId: question.id,
        selectedAnswerIndex: selectedAnswer,
        status: status,
        correctAnswerIndex: question.correctAnswerIndex,
      );
    }).toList();

    // İstatistikleri hesapla
    final totalQuestions = answerResults.length;
    final correctAnswers =
        answerResults.where((a) => a.status == AnswerStatus.correct).length;
    final wrongAnswers =
        answerResults.where((a) => a.status == AnswerStatus.wrong).length;
    final emptyAnswers =
        answerResults.where((a) => a.status == AnswerStatus.empty).length;
    final successPercentage = (correctAnswers / totalQuestions) * 100;

    // Kazanım bazlı istatistikler (doğru sayısı)
    final learningOutcomeStats = <String, int>{};
    for (final answer in answerResults) {
      if (answer.status == AnswerStatus.correct) {
        final question = test.questions.firstWhere((q) => q.id == answer.questionId);
        final outcomeId = question.learningOutcome.id;
        learningOutcomeStats[outcomeId] =
            (learningOutcomeStats[outcomeId] ?? 0) + 1;
      }
    }

    final result = MockTestResult(
      testId: test.id,
      testTitle: test.title,
      answers: answerResults,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      emptyAnswers: emptyAnswers,
      successPercentage: successPercentage,
      completedAt: DateTime.now(),
      learningOutcomeStats: learningOutcomeStats,
    );

    // Sonucu kaydet (gerçek uygulamada API'ye gönderilecek)
    _saveResult(result);

    state = state.copyWith(currentResult: result);
  }

  void resetCurrentTest() {
    state = state.copyWith(
      currentTest: null,
      currentResult: null,
    );
  }

  // Simüle edilmiş veri oluşturma fonksiyonları
  List<LearningOutcome> _generateLearningOutcomes() {
    // Deneme testleri için karışık kazanımlar
    return [
      AppLearningOutcomes.paragraftaAnlam,
      AppLearningOutcomes.cumledeAnlam,
      AppLearningOutcomes.kelimeAnlami,
      AppLearningOutcomes.sesBilgisi,
      AppLearningOutcomes.ekler,
    ];
  }

  List<Question> _generateQuestions(
      List<LearningOutcome> outcomes, int count) {
    final questions = <Question>[];

    for (int i = 0; i < count; i++) {
      final outcomeIndex = i % outcomes.length;
      final outcome = outcomes[outcomeIndex];

      questions.add(Question(
        id: 'q_$i',
        text:
            'Soru ${i + 1}: Bu bir örnek deneme sorusudur. Karışık kazanımlardan oluşmaktadır.',
        options: [
          'Seçenek A: İlk seçenek',
          'Seçenek B: İkinci seçenek',
          'Seçenek C: Üçüncü seçenek',
          'Seçenek D: Dördüncü seçenek',
        ],
        correctAnswerIndex: i % 4,
        learningOutcome: outcome,
        explanation: 'Bu sorunun açıklaması burada yer alacak.',
      ));
    }

    return questions;
  }

  // Sonuçları kaydetme (simüle edilmiş - gerçek uygulamada API'ye gönderilecek)
  final List<MockTestResult> _savedResults = [];

  void _saveResult(MockTestResult result) {
    _savedResults.insert(0, result);
    // Son 10 testi tut
    if (_savedResults.length > 10) {
      _savedResults.removeLast();
    }
  }

  List<MockTestResult> getSavedResults() => _savedResults;
}

final mockTestProvider =
    StateNotifierProvider<MockTestNotifier, MockTestState>((ref) {
  return MockTestNotifier();
});

