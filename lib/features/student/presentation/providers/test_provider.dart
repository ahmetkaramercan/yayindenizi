import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../domain/entities/test.dart';
import '../../domain/entities/test_result.dart';
import '../../domain/utils/test_result_calculator.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/test_repository.dart';

class TestState {
  final Test? test;
  final TestResult? testResult;
  final bool isLoading;
  final String? error;
  final bool alreadySolved;

  TestState({
    this.test,
    this.testResult,
    this.isLoading = false,
    this.error,
    this.alreadySolved = false,
  });

  TestState copyWith({
    Test? test,
    TestResult? testResult,
    bool? isLoading,
    String? error,
    bool? alreadySolved,
  }) {
    return TestState(
      test: test ?? this.test,
      testResult: testResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      alreadySolved: alreadySolved ?? this.alreadySolved,
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

      final existingResult = await _checkExistingResult(testId, test);
      if (existingResult != null) {
        state = state.copyWith(
          test: test,
          testResult: existingResult,
          isLoading: false,
          alreadySolved: true,
        );
        return;
      }

      state = state.copyWith(test: test, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<TestResult?> _checkExistingResult(String testId, Test test) async {
    try {
      final data = await _testRepo.getResultForTest(testId);
      if (data == null) return null;

      final answersData = data['answers'] as List? ?? [];
      final answers = TestResultCalculator.answersFromApi(answersData);
      final calc = TestResultCalculator.calculate(
        questions: test.questions,
        answers: answers,
      );

      final answerResults = calc.answers
          .map((a) => AnswerResult(
                questionId: a.questionId,
                selectedAnswerIndex: a.selectedIndex,
                isCorrect: a.isCorrect,
                correctAnswerIndex: a.correctAnswerIndex,
              ))
          .toList();

      final learningOutcomeStats = calc.outcomeStats.entries.map((entry) {
        final data = entry.value;
        final matchingQ = test.questions.where(
          (q) => (q.learningOutcome?.id ?? 'general') == entry.key,
        );
        final outcome = matchingQ.isNotEmpty ? matchingQ.first.learningOutcome : null;

        return LearningOutcomeStats(
          learningOutcome: outcome ?? const LearningOutcome(id: 'general', name: 'Genel'),
          totalQuestions: data.total,
          correctAnswers: data.correct,
          wrongAnswers: data.wrong,
          successPercentage: data.percentage,
        );
      }).toList();

      return TestResult(
        testId: testId,
        level: test.level,
        answers: answerResults,
        totalQuestions: calc.totalQuestions,
        correctAnswers: calc.correctAnswers,
        wrongAnswers: calc.wrongAnswers,
        successPercentage: calc.successPercentage,
        learningOutcomeStats: learningOutcomeStats,
      );
    } catch (e) {
      dev.log('Failed to check existing result: $e', name: 'TestNotifier');
      return null;
    }
  }

  void finishTest(Map<String, int?> answers) {
    final test = state.test;
    if (test == null) return;

    final calc = TestResultCalculator.calculate(
      questions: test.questions,
      answers: answers,
    );

    final answerResults = calc.answers
        .map((a) => AnswerResult(
              questionId: a.questionId,
              selectedAnswerIndex: a.selectedIndex,
              isCorrect: a.isCorrect,
              correctAnswerIndex: a.correctAnswerIndex,
            ))
        .toList();

    final learningOutcomeStats = calc.outcomeStats.entries.map((entry) {
      final data = entry.value;
      final matchingQ = test.questions.where(
        (q) => (q.learningOutcome?.id ?? 'general') == entry.key,
      );
      final outcome = matchingQ.isNotEmpty ? matchingQ.first.learningOutcome : null;

      return LearningOutcomeStats(
        learningOutcome: outcome ?? const LearningOutcome(id: 'general', name: 'Genel'),
        totalQuestions: data.total,
        correctAnswers: data.correct,
        wrongAnswers: data.wrong,
        successPercentage: data.percentage,
      );
    }).toList();

    final result = TestResult(
      testId: test.id,
      level: test.level,
      answers: answerResults,
      totalQuestions: calc.totalQuestions,
      correctAnswers: calc.correctAnswers,
      wrongAnswers: calc.wrongAnswers,
      successPercentage: calc.successPercentage,
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
      dev.log('Test result submitted for test $testId', name: 'TestNotifier');
    } catch (e) {
      dev.log('Failed to submit test result: $e', name: 'TestNotifier');
    }
  }

  void resetTest() {
    state = TestState();
  }
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  return TestNotifier();
});
