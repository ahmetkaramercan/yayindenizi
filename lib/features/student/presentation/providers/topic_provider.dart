import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_test.dart';
import '../../domain/entities/topic_test_result.dart';
import '../../domain/utils/test_result_calculator.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/test_repository.dart';

class TopicState {
  final List<Topic> topics;
  final Topic? currentTopic;
  final List<TopicTest> topicTests;
  final TopicTest? currentTopicTest;
  final TopicTestResult? currentTopicResult;
  final Map<String, TopicLearningOutcomeStats>? topicAnalysis;
  final bool isLoading;
  final String? error;
  final bool alreadySolved;

  TopicState({
    this.topics = const [],
    this.currentTopic,
    this.topicTests = const [],
    this.currentTopicTest,
    this.currentTopicResult,
    this.topicAnalysis,
    this.isLoading = false,
    this.error,
    this.alreadySolved = false,
  });

  TopicState copyWith({
    List<Topic>? topics,
    Topic? currentTopic,
    List<TopicTest>? topicTests,
    TopicTest? currentTopicTest,
    TopicTestResult? currentTopicResult,
    Map<String, TopicLearningOutcomeStats>? topicAnalysis,
    bool? isLoading,
    String? error,
    bool? alreadySolved,
  }) {
    return TopicState(
      topics: topics ?? this.topics,
      currentTopic: currentTopic ?? this.currentTopic,
      topicTests: topicTests ?? this.topicTests,
      currentTopicTest: currentTopicTest,
      currentTopicResult: currentTopicResult,
      topicAnalysis: topicAnalysis ?? this.topicAnalysis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      alreadySolved: alreadySolved ?? this.alreadySolved,
    );
  }
}

class TopicNotifier extends StateNotifier<TopicState> {
  TopicNotifier() : super(TopicState()) {
    loadTopics();
  }

  final _testRepo = sl<TestRepository>();
  final List<TopicTestResult> _savedResults = [];

  /// The bookId for konu kitapları. Will be fetched dynamically once books are loaded.
  /// For now we hardcode the seeded book ID pattern.
  String? _bookId;

  void setBookId(String bookId) {
    if (_bookId != bookId) {
      _bookId = bookId;
      loadTopics();
    }
  }

  Future<void> loadTopics() async {
    if (_bookId == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topics = await _testRepo.getSections(_bookId!);

      state = state.copyWith(
        topics: topics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTopic(String topicId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topic = state.topics.firstWhere(
        (t) => t.id == topicId,
        orElse: () => Topic(id: topicId, title: ''),
      );

      state = state.copyWith(
        currentTopic: topic,
        isLoading: false,
      );

      await loadTopicTests(topicId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTopicTests(String topicId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tests = await _testRepo.getTestsBySection(topicId);
      final topic = state.currentTopic ?? Topic(id: topicId, title: '');

      final topicTests = tests.map((t) => TopicTest(
        id: t.id,
        title: t.title,
        description: t.description ?? '',
        topic: topic,
        questions: t.questions,
      )).toList();

      state = state.copyWith(
        topicTests: topicTests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTopicTest(String testId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final fullTest = await _testRepo.getTest(testId);
      final topic = state.currentTopic ?? Topic(id: '', title: '');

      final topicTest = TopicTest(
        id: fullTest.id,
        title: fullTest.title,
        description: fullTest.description ?? '',
        topic: topic,
        questions: fullTest.questions,
      );

      final existingResult = await _checkExistingResult(testId, topicTest, topic);
      if (existingResult != null) {
        _savedResults.add(existingResult);
        state = state.copyWith(
          currentTopicTest: topicTest,
          currentTopicResult: existingResult,
          isLoading: false,
          alreadySolved: true,
        );
        return;
      }

      state = state.copyWith(
        currentTopicTest: topicTest,
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

  Future<TopicTestResult?> _checkExistingResult(
    String testId,
    TopicTest test,
    Topic topic,
  ) async {
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
          .map((a) => TopicAnswerResult(
                questionId: a.questionId,
                selectedAnswerIndex: a.selectedIndex,
                isCorrect: a.isCorrect,
                correctAnswerIndex: a.correctAnswerIndex,
              ))
          .toList();

      final learningOutcomeStats = calc.outcomeStats.map((outcomeId, data) {
        final matchingQ = test.questions.where(
          (q) => (q.learningOutcome?.id ?? 'general') == outcomeId,
        );
        final outcome = matchingQ.isNotEmpty ? matchingQ.first.learningOutcome : null;

        return MapEntry(
          outcomeId,
          TopicLearningOutcomeStats(
            learningOutcome: outcome ?? const LearningOutcome(id: 'general', name: 'Genel'),
            totalQuestions: data.total,
            correctAnswers: data.correct,
            wrongAnswers: data.wrong,
            successPercentage: data.percentage,
          ),
        );
      });

      return TopicTestResult(
        testId: testId,
        testTitle: test.title,
        topicId: topic.id,
        topicTitle: topic.title,
        answers: answerResults,
        totalQuestions: calc.totalQuestions,
        correctAnswers: calc.correctAnswers,
        wrongAnswers: calc.wrongAnswers,
        successPercentage: calc.successPercentage,
        completedAt: DateTime.tryParse(data['finishedAt']?.toString() ?? '') ?? DateTime.now(),
        learningOutcomeStats: learningOutcomeStats,
      );
    } catch (e) {
      dev.log('Failed to check existing result: $e', name: 'TopicNotifier');
      return null;
    }
  }

  void finishTopicTest(Map<String, int?> answers) {
    final test = state.currentTopicTest;
    if (test == null) return;

    final calc = TestResultCalculator.calculate(
      questions: test.questions,
      answers: answers,
    );

    final answerResults = calc.answers
        .map((a) => TopicAnswerResult(
              questionId: a.questionId,
              selectedAnswerIndex: a.selectedIndex,
              isCorrect: a.isCorrect,
              correctAnswerIndex: a.correctAnswerIndex,
            ))
        .toList();

    final learningOutcomeStats = calc.outcomeStats.map((outcomeId, data) {
      final matchingQ = test.questions.where(
        (q) => (q.learningOutcome?.id ?? 'general') == outcomeId,
      );
      final outcome = matchingQ.isNotEmpty ? matchingQ.first.learningOutcome : null;

      return MapEntry(
        outcomeId,
        TopicLearningOutcomeStats(
          learningOutcome: outcome ?? const LearningOutcome(id: 'general', name: 'Genel'),
          totalQuestions: data.total,
          correctAnswers: data.correct,
          wrongAnswers: data.wrong,
          successPercentage: data.percentage,
        ),
      );
    });

    final result = TopicTestResult(
      testId: test.id,
      testTitle: test.title,
      topicId: test.topic.id,
      topicTitle: test.topic.title,
      answers: answerResults,
      totalQuestions: calc.totalQuestions,
      correctAnswers: calc.correctAnswers,
      wrongAnswers: calc.wrongAnswers,
      successPercentage: calc.successPercentage,
      completedAt: DateTime.now(),
      learningOutcomeStats: learningOutcomeStats,
    );

    _savedResults.add(result);
    state = state.copyWith(currentTopicResult: result);

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
      dev.log('Test result submitted for test $testId', name: 'TopicNotifier');
    } catch (e) {
      dev.log('Failed to submit test result: $e', name: 'TopicNotifier');
    }
  }

  Future<void> loadTopicAnalysis(String topicId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch results from backend for all tests in this section
      await _loadResultsFromBackend(topicId);

      final topicResults = _savedResults.where((r) => r.topicId == topicId).toList();

      if (topicResults.isEmpty) {
        state = state.copyWith(topicAnalysis: null, isLoading: false);
        return;
      }

      final combinedStats = <String, TopicLearningOutcomeStats>{};

      for (final result in topicResults) {
        for (final entry in result.learningOutcomeStats.entries) {
          final outcomeId = entry.key;
          final stats = entry.value;

          if (!combinedStats.containsKey(outcomeId)) {
            combinedStats[outcomeId] = TopicLearningOutcomeStats(
              learningOutcome: stats.learningOutcome,
              totalQuestions: 0,
              correctAnswers: 0,
              wrongAnswers: 0,
              successPercentage: 0,
            );
          }

          final current = combinedStats[outcomeId]!;
          final total = current.totalQuestions + stats.totalQuestions;
          final correct = current.correctAnswers + stats.correctAnswers;
          final wrong = current.wrongAnswers + stats.wrongAnswers;
          final double percentage = total > 0 ? (correct / total) * 100 : 0.0;

          combinedStats[outcomeId] = TopicLearningOutcomeStats(
            learningOutcome: stats.learningOutcome,
            totalQuestions: total,
            correctAnswers: correct,
            wrongAnswers: wrong,
            successPercentage: percentage,
          );
        }
      }

      state = state.copyWith(
        topicAnalysis: combinedStats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadResultsFromBackend(String topicId) async {
    try {
      final tests = state.topicTests;
      for (final test in tests) {
        final alreadyHave = _savedResults.any((r) => r.testId == test.id);
        if (alreadyHave) continue;

        final data = await _testRepo.getResultForTest(test.id);
        if (data == null) continue;

        final topic = state.currentTopic ?? Topic(id: topicId, title: '');
        final fullTest = TopicTest(
          id: test.id,
          title: test.title,
          description: test.description,
          topic: topic,
          questions: test.questions,
        );

        final result = await _checkExistingResult(test.id, fullTest, topic);
        if (result != null) {
          _savedResults.add(result);
        }
      }
    } catch (e) {
      dev.log('Failed to load results from backend: $e', name: 'TopicNotifier');
    }
  }

  void resetCurrentTest() {
    state = state.copyWith(
      currentTopicTest: null,
      currentTopicResult: null,
    );
  }
}

final topicProvider =
    StateNotifierProvider<TopicNotifier, TopicState>((ref) {
  return TopicNotifier();
});
