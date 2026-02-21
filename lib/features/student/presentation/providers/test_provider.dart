import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../domain/entities/test.dart';
import '../../domain/entities/test_result.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/test_repository.dart';

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

  final _testRepo = sl<TestRepository>();

  Future<void> loadTest(int level) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Level-based tests: testId = 'test_$level' pattern from backend seeding
      // For Paragraf Koçu, each level maps to a test in the seeded book's section
      final test = await _testRepo.getTest('test_$level');

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

  Future<void> loadTestById(String testId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final test = await _testRepo.getTest(testId);
      state = state.copyWith(test: test, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void finishTest(Map<String, int?> answers) {
    final test = state.test;
    if (test == null) return;

    final answerResults = test.questions.map((question) {
      final selectedAnswer = answers[question.id];
      final isCorrect = selectedAnswer != null && selectedAnswer == question.correctAnswerIndex;

      return AnswerResult(
        questionId: question.id,
        selectedAnswerIndex: selectedAnswer,
        isCorrect: isCorrect,
        correctAnswerIndex: question.correctAnswerIndex,
      );
    }).toList();

    final totalQuestions = answerResults.length;
    final correctAnswers = answerResults.where((a) => a.isCorrect).length;
    final wrongAnswers = answerResults.where((a) => !a.isCorrect && a.selectedAnswerIndex != null).length;
    final successPercentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions) * 100
        : 0.0;

    final learningOutcomeMap = <String, List<AnswerResult>>{};

    for (final answer in answerResults) {
      final question = test.questions.firstWhere((q) => q.id == answer.questionId);
      final outcomeId = question.learningOutcome?.id ?? 'general';

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
      final percentage = total > 0 ? (correct / total) * 100 : 0.0;

      final outcome = test.questions
          .where((q) => (q.learningOutcome?.id ?? 'general') == outcomeId)
          .first
          .learningOutcome;

      return LearningOutcomeStats(
        learningOutcome: outcome ?? const LearningOutcome(id: 'general', name: 'Genel'),
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

    _submitResultToBackend(test.id, answers);
  }

  Future<void> _submitResultToBackend(
    String testId,
    Map<String, int?> answers,
  ) async {
    try {
      final answerList = answers.entries
          .map((e) => {
                'questionId': e.key,
                'selectedIndex': e.value,
              })
          .toList();

      await _testRepo.submitResult(
        testId: testId,
        answers: answerList,
        totalTime: 0,
      );
    } catch (_) {}
  }

  void resetTest() {
    state = TestState();
  }
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier();
});
