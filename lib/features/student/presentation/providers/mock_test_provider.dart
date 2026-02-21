import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mock_test.dart';
import '../../domain/entities/mock_test_result.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/test_repository.dart';

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

      state = state.copyWith(
        currentTest: mockTest,
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

    final totalQuestions = answerResults.length;
    final correctAnswers =
        answerResults.where((a) => a.status == AnswerStatus.correct).length;
    final wrongAnswers =
        answerResults.where((a) => a.status == AnswerStatus.wrong).length;
    final emptyAnswers =
        answerResults.where((a) => a.status == AnswerStatus.empty).length;
    final successPercentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions) * 100
        : 0.0;

    final learningOutcomeStats = <String, int>{};
    for (final answer in answerResults) {
      if (answer.status == AnswerStatus.correct) {
        final question = test.questions.firstWhere((q) => q.id == answer.questionId);
        final outcomeId = question.learningOutcome?.id ?? 'general';
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
    } catch (_) {}
  }
}

final mockTestProvider =
    StateNotifierProvider<MockTestNotifier, MockTestState>((ref) {
  return MockTestNotifier();
});
