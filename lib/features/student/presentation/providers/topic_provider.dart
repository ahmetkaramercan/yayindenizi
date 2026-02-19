import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_test.dart';
import '../../domain/entities/topic_test_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../../../core/constants/learning_outcomes.dart';

class TopicState {
  final List<Topic> topics;
  final Topic? currentTopic;
  final List<TopicTest> topicTests;
  final TopicTest? currentTopicTest;
  final TopicTestResult? currentTopicResult;
  final Map<String, TopicLearningOutcomeStats>? topicAnalysis;
  final bool isLoading;
  final String? error;

  TopicState({
    this.topics = const [],
    this.currentTopic,
    this.topicTests = const [],
    this.currentTopicTest,
    this.currentTopicResult,
    this.topicAnalysis,
    this.isLoading = false,
    this.error,
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
    );
  }
}

class TopicNotifier extends StateNotifier<TopicState> {
  TopicNotifier() : super(TopicState()) {
    loadTopics();
  }

  // Sonuçları saklamak için (simüle edilmiş)
  final List<TopicTestResult> _savedResults = [];

  Future<void> loadTopics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den konu listesini getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş konu listesi
      final learningOutcomes = _generateLearningOutcomes();
      
      final topics = [
        Topic(
          id: 'topic_1',
          title: 'Paragraf Analizi',
          description: 'Paragraf analizi konuları ve teknikleri',
          learningOutcomes: learningOutcomes.take(3).toList(),
          testCount: 5,
        ),
        Topic(
          id: 'topic_2',
          title: 'Cümle Bilgisi',
          description: 'Cümle yapısı ve cümle türleri',
          learningOutcomes: learningOutcomes.skip(1).take(2).toList(),
          testCount: 4,
        ),
        Topic(
          id: 'topic_3',
          title: 'Anlam Bilgisi',
          description: 'Kelimelerin anlamları ve kullanımları',
          learningOutcomes: learningOutcomes.skip(2).take(2).toList(),
          testCount: 3,
        ),
      ];

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
      // TODO: API'den konu detayını getir
      await Future.delayed(const Duration(milliseconds: 500));

      final topic = state.topics.firstWhere(
        (t) => t.id == topicId,
        orElse: () => state.topics.first,
      );

      state = state.copyWith(
        currentTopic: topic,
        isLoading: false,
      );

      // Konu testlerini de yükle
      loadTopicTests(topicId);
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
      // TODO: API'den konu testlerini getir
      await Future.delayed(const Duration(milliseconds: 500));

      final topic = state.topics.firstWhere(
        (t) => t.id == topicId,
        orElse: () => state.topics.first,
      );

      final learningOutcomes = topic.learningOutcomes;
      final tests = List.generate(3, (index) {
        final questions = _generateQuestions(learningOutcomes, 10);

        return TopicTest(
          id: 'test_${topicId}_${index + 1}',
          title: '${topic.title} - Test ${index + 1}',
          description: '${topic.title} konusuna ait test ${index + 1}',
          topic: topic,
          questions: questions,
        );
      });

      state = state.copyWith(
        topicTests: tests,
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
      // TODO: API'den test detayını getir
      await Future.delayed(const Duration(milliseconds: 500));

      final test = state.topicTests.firstWhere(
        (t) => t.id == testId,
        orElse: () => state.topicTests.first,
      );

      state = state.copyWith(
        currentTopicTest: test,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void finishTopicTest(Map<String, int?> answers) {
    final test = state.currentTopicTest;
    if (test == null) return;

    // Cevapları işle
    final answerResults = test.questions.map((question) {
      final selectedAnswer = answers[question.id];
      final isCorrect = selectedAnswer == question.correctAnswerIndex;

      return TopicAnswerResult(
        questionId: question.id,
        selectedAnswerIndex: selectedAnswer,
        isCorrect: isCorrect,
        correctAnswerIndex: question.correctAnswerIndex,
      );
    }).toList();

    // İstatistikleri hesapla
    final totalQuestions = answerResults.length;
    final correctAnswers =
        answerResults.where((a) => a.isCorrect).length;
    final wrongAnswers = totalQuestions - correctAnswers;
    final successPercentage = (correctAnswers / totalQuestions) * 100;

    // Kazanım bazlı istatistikleri hesapla
    final learningOutcomeMap = <String, List<TopicAnswerResult>>{};

    for (final answer in answerResults) {
      final question = test.questions.firstWhere((q) => q.id == answer.questionId);
      final outcomeId = question.learningOutcome.id;

      if (!learningOutcomeMap.containsKey(outcomeId)) {
        learningOutcomeMap[outcomeId] = [];
      }
      learningOutcomeMap[outcomeId]!.add(answer);
    }

    final learningOutcomeStats = learningOutcomeMap.map((outcomeId, answers) {
      final total = answers.length;
      final correct = answers.where((a) => a.isCorrect).length;
      final wrong = total - correct;
      final percentage = (correct / total) * 100;

      final outcome = test.questions
          .firstWhere((q) => q.learningOutcome.id == outcomeId)
          .learningOutcome;

      return MapEntry(
        outcomeId,
        TopicLearningOutcomeStats(
          learningOutcome: outcome,
          totalQuestions: total,
          correctAnswers: correct,
          wrongAnswers: wrong,
          successPercentage: percentage,
        ),
      );
    });

    final result = TopicTestResult(
      testId: test.id,
      testTitle: test.title,
      topicId: test.topic.id,
      topicTitle: test.topic.title,
      answers: answerResults,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      successPercentage: successPercentage,
      completedAt: DateTime.now(),
      learningOutcomeStats: learningOutcomeStats,
    );

    // Sonucu kaydet
    _savedResults.add(result);

    state = state.copyWith(currentTopicResult: result);
  }

  Future<void> loadTopicAnalysis(String topicId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den konu analizini getir
      await Future.delayed(const Duration(seconds: 1));

      // Bu konuya ait tüm sonuçları filtrele
      final topicResults = _savedResults.where((r) => r.topicId == topicId).toList();

      if (topicResults.isEmpty) {
        state = state.copyWith(
          topicAnalysis: null,
          isLoading: false,
        );
        return;
      }

      // Kazanım bazlı istatistikleri topla
      final learningOutcomeMap = <String, List<TopicAnswerResult>>{};

      for (final result in topicResults) {
        for (final answer in result.answers) {
          // Sorunun kazanımını bulmak için result'tan alıyoruz
          // Gerçek uygulamada bu bilgi result'ta saklanmalı
          final questionId = answer.questionId;
          
          // Basit bir yaklaşım: Her result'ta learningOutcomeStats var
          // Bu bilgiyi kullanarak kazanım bazlı analiz yapabiliriz
        }
      }

      // Result'lardaki learningOutcomeStats'ları birleştir
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
          final percentage = total > 0 ? (correct / total) * 100 : 0;

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

  void resetCurrentTest() {
    state = state.copyWith(
      currentTopicTest: null,
      currentTopicResult: null,
    );
  }

  // Simüle edilmiş veri oluşturma fonksiyonları
  List<LearningOutcome> _generateLearningOutcomes() {
    // Konu bazlı testler için kazanımlar
    return [
      AppLearningOutcomes.paragraftaAnlam,
      AppLearningOutcomes.cumledeAnlam,
      AppLearningOutcomes.kelimeAnlami,
      AppLearningOutcomes.sesBilgisi,
      AppLearningOutcomes.sozcukTurleri,
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
            'Soru ${i + 1}: Bu konu bazlı bir test sorusudur. ${outcome.name} kazanımına aittir.',
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
}

final topicProvider =
    StateNotifierProvider<TopicNotifier, TopicState>((ref) {
  return TopicNotifier();
});

