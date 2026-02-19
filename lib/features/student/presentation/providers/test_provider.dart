import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/test.dart';
import '../../domain/entities/test_result.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../domain/entities/question.dart';
import '../../../../core/constants/learning_outcomes.dart';

class TestState {
  final Test? test;
  final TestResult? testResult;
  final bool isLoading;
  final String? error;

  TestState({
    this.test,
    this.testResult,
    this.isLoading = false,
    this.error,
  });

  TestState copyWith({
    Test? test,
    TestResult? testResult,
    bool? isLoading,
    String? error,
  }) {
    return TestState(
      test: test ?? this.test,
      testResult: testResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TestNotifier extends StateNotifier<TestState> {
  TestNotifier() : super(TestState());

  Future<void> loadTest(int level) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den test verilerini getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş test verisi
      final learningOutcomes = _generateLearningOutcomes();
      final questions = _generateQuestions(level, learningOutcomes);
      
      final test = Test(
        id: 'test_$level',
        title: 'Paragraf Koçu - Seviye $level',
        description: 'Seviye $level testi',
        questions: questions,
        level: level,
      );

      state = state.copyWith(
        test: test,
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
    final test = state.test;
    if (test == null) return;

    // Cevapları işle
    final answerResults = test.questions.map((question) {
      final selectedAnswer = answers[question.id];
      final isCorrect = selectedAnswer == question.correctAnswerIndex;

      return AnswerResult(
        questionId: question.id,
        selectedAnswerIndex: selectedAnswer,
        isCorrect: isCorrect,
        correctAnswerIndex: question.correctAnswerIndex,
      );
    }).toList();

    // İstatistikleri hesapla
    final totalQuestions = answerResults.length;
    final correctAnswers = answerResults.where((a) => a.isCorrect).length;
    final wrongAnswers = totalQuestions - correctAnswers;
    final successPercentage = (correctAnswers / totalQuestions) * 100;

    // Kazanım bazlı istatistikleri hesapla
    final learningOutcomeMap = <String, List<AnswerResult>>{};
    
    for (final answer in answerResults) {
      final question = test.questions.firstWhere((q) => q.id == answer.questionId);
      final outcomeId = question.learningOutcome.id;
      
      if (!learningOutcomeMap.containsKey(outcomeId)) {
        learningOutcomeMap[outcomeId] = [];
      }
      learningOutcomeMap[outcomeId]!.add(answer);
    }

    final learningOutcomeStats = learningOutcomeMap.entries.map((entry) {
      final outcomeId = entry.key;
      final answers = entry.value;
      final total = answers.length;
      final correct = answers.where((a) => a.isCorrect).length;
      final wrong = total - correct;
      final percentage = (correct / total) * 100;

      final outcome = test.questions
          .firstWhere((q) => q.learningOutcome.id == outcomeId)
          .learningOutcome;

      return LearningOutcomeStats(
        learningOutcome: outcome,
        totalQuestions: total,
        correctAnswers: correct,
        wrongAnswers: wrong,
        successPercentage: percentage,
      );
    }).toList();

    final result = TestResult(
      testId: test.id,
      level: test.level,
      answers: answerResults,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      successPercentage: successPercentage,
      learningOutcomeStats: learningOutcomeStats,
    );

    state = state.copyWith(testResult: result);
  }

  void resetTest() {
    state = TestState();
  }

  // Simüle edilmiş veri oluşturma fonksiyonları
  List<LearningOutcome> _generateLearningOutcomes() {
    // Paragraf Koçu için kazanımlar
    return [
      AppLearningOutcomes.paragraftaAnlam,
      AppLearningOutcomes.paragrafYapisi,
      AppLearningOutcomes.cumledeAnlam,
      AppLearningOutcomes.kelimeAnlami,
    ];
  }

  List<Question> _generateQuestions(int level, List<LearningOutcome> outcomes) {
    final questions = <Question>[];
    
    // Her seviye için 10 soru oluştur
    for (int i = 0; i < 10; i++) {
      final outcomeIndex = i % outcomes.length;
      final outcome = outcomes[outcomeIndex];
      
      questions.add(Question(
        id: 'q_${level}_$i',
        text: 'Seviye $level - Soru ${i + 1}: Bu bir örnek paragraf sorusudur. Paragrafın ana düşüncesi nedir?',
        options: [
          'Seçenek A: İlk seçenek',
          'Seçenek B: İkinci seçenek',
          'Seçenek C: Üçüncü seçenek',
          'Seçenek D: Dördüncü seçenek',
        ],
        correctAnswerIndex: i % 4, // Rastgele doğru cevap
        learningOutcome: outcome,
        explanation: 'Bu sorunun açıklaması burada yer alacak.',
      ));
    }
    
    return questions;
  }
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier();
});

