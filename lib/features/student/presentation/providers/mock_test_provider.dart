import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../domain/entities/mock_test.dart';
import '../../domain/entities/mock_test_result.dart';
import '../../domain/utils/test_result_calculator.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/test_repository.dart';

class MockTestState {
  final List<MockTest> tests;
  final MockTest? currentTest;
  final MockTestResult? currentResult;
  final bool isLoading;
  final String? error;
  final bool alreadySolved;

  MockTestState({
    this.tests = const [],
    this.currentTest,
    this.currentResult,
    this.isLoading = false,
    this.error,
    this.alreadySolved = false,
  });

  MockTestState copyWith({
    List<MockTest>? tests,
    MockTest? currentTest,
    MockTestResult? currentResult,
    bool? isLoading,
    String? error,
    bool? alreadySolved,
  }) {
    return MockTestState(
      tests: tests ?? this.tests,
      currentTest: currentTest,
      currentResult: currentResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      alreadySolved: alreadySolved ?? this.alreadySolved,
    );
  }
}

class MockTestNotifier extends StateNotifier<MockTestState> {
  MockTestNotifier() : super(MockTestState());

  final _testRepo = sl<TestRepository>();
  final List<MockTestResult> _savedResults = [];

  String? _bookId;

  void setBookId(String bookId) {
    if (_bookId != bookId) {
      _bookId = bookId;
      loadTests();
    }
  }

  Future<void> loadTests() async {
    if (_bookId == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sections = await _testRepo.getSections(_bookId!);

      final allTests = <MockTest>[];
      for (final section in sections) {
        final tests = await _testRepo.getTestsBySection(section.id);
        for (final test in tests) {
          allTests.add(MockTest(
            id: test.id,
            title: test.title,
            description: test.description ?? '',
            questions: test.questions,
          ));
        }
      }

      state = state.copyWith(
        tests: allTests,
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
      final fullTest = await _testRepo.getTest(testId);

      final mockTest = MockTest(
        id: fullTest.id,
        title: fullTest.title,
        description: fullTest.description ?? '',
        questions: fullTest.questions,
      );

      final existingResult = await _checkExistingResult(testId, mockTest);
      if (existingResult != null) {
        _saveResult(existingResult);
        state = state.copyWith(
          currentTest: mockTest,
          currentResult: existingResult,
          isLoading: false,
          alreadySolved: true,
        );
        return;
      }

      state = state.copyWith(
        currentTest: mockTest,
        isLoading: false,
        alreadySolved: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<MockTestResult?> _checkExistingResult(String testId, MockTest test) async {
    try {
      final data = await _testRepo.getResultForTest(testId);
      if (data == null) return null;

      final answersData = data['answers'] as List? ?? [];
      final answers = TestResultCalculator.answersFromApi(answersData);
      final calc = TestResultCalculator.calculate(
        questions: test.questions,
        answers: answers,
      );

      final answerResults = calc.answers.map((a) {
        AnswerStatus status;
        if (a.isEmpty) {
          status = AnswerStatus.empty;
        } else if (a.isCorrect) {
          status = AnswerStatus.correct;
        } else {
          status = AnswerStatus.wrong;
        }
        return MockAnswerResult(
          questionId: a.questionId,
          selectedAnswerIndex: a.selectedIndex,
          status: status,
          correctAnswerIndex: a.correctAnswerIndex,
        );
      }).toList();

      final learningOutcomeStats = calc.outcomeStats.map(
        (k, v) => MapEntry(k, v.correct),
      );

      final learningOutcomeStatsList = calc.outcomeStats.entries.map((e) {
        final matchingQ = test.questions.where(
          (q) => (q.learningOutcome?.id ?? 'general') == e.key,
        );
        final outcome = matchingQ.isNotEmpty
            ? matchingQ.first.learningOutcome
            : null;
        return MockLearningOutcomeStats(
          learningOutcome: outcome ?? const LearningOutcome(id: 'general', name: 'Genel'),
          totalQuestions: e.value.total,
          correctAnswers: e.value.correct,
          wrongAnswers: e.value.wrong,
          successPercentage: e.value.percentage,
        );
      }).toList();

      return MockTestResult(
        testId: testId,
        testTitle: test.title,
        answers: answerResults,
        totalQuestions: calc.totalQuestions,
        correctAnswers: calc.correctAnswers,
        wrongAnswers: calc.wrongAnswers,
        emptyAnswers: calc.emptyAnswers,
        successPercentage: calc.successPercentage,
        completedAt: DateTime.tryParse(data['finishedAt']?.toString() ?? '') ?? DateTime.now(),
        learningOutcomeStats: learningOutcomeStats,
        learningOutcomeStatsList: learningOutcomeStatsList,
      );
    } catch (e) {
      dev.log('Failed to check existing result: $e', name: 'MockTestNotifier');
      return null;
    }
  }

  void finishTest(Map<String, int?> answers) {
    final test = state.currentTest;
    if (test == null) return;

    final calc = TestResultCalculator.calculate(
      questions: test.questions,
      answers: answers,
    );

    final answerResults = calc.answers.map((a) {
      AnswerStatus status;
      if (a.isEmpty) {
        status = AnswerStatus.empty;
      } else if (a.isCorrect) {
        status = AnswerStatus.correct;
      } else {
        status = AnswerStatus.wrong;
      }
      return MockAnswerResult(
        questionId: a.questionId,
        selectedAnswerIndex: a.selectedIndex,
        status: status,
        correctAnswerIndex: a.correctAnswerIndex,
      );
    }).toList();

    final learningOutcomeStats = calc.outcomeStats.map(
      (k, v) => MapEntry(k, v.correct),
    );

    final result = MockTestResult(
      testId: test.id,
      testTitle: test.title,
      answers: answerResults,
      totalQuestions: calc.totalQuestions,
      correctAnswers: calc.correctAnswers,
      wrongAnswers: calc.wrongAnswers,
      emptyAnswers: calc.emptyAnswers,
      successPercentage: calc.successPercentage,
      completedAt: DateTime.now(),
      learningOutcomeStats: learningOutcomeStats,
    );

    _saveResult(result);
    state = state.copyWith(currentResult: result);

    _submitResultToBackend(test.id, answers);
  }

  void resetCurrentTest() {
    state = state.copyWith(
      currentTest: null,
      currentResult: null,
    );
  }

  void _saveResult(MockTestResult result) {
    _savedResults.insert(0, result);
    if (_savedResults.length > 10) {
      _savedResults.removeLast();
    }
  }

  List<MockTestResult> getSavedResults() => _savedResults;

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
      dev.log('Test result submitted for test $testId', name: 'MockTestNotifier');
    } catch (e) {
      dev.log('Failed to submit test result: $e', name: 'MockTestNotifier');
    }
  }
}

final mockTestProvider =
    StateNotifierProvider<MockTestNotifier, MockTestState>((ref) {
  return MockTestNotifier();
});
