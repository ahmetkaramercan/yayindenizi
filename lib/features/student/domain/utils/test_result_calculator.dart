import '../entities/question.dart';

/// Hesaplanan tek cevap.
class CalculatedAnswer {
  final String questionId;
  final int? selectedIndex;
  final bool isCorrect;
  final bool isEmpty;
  final int correctAnswerIndex;

  const CalculatedAnswer({
    required this.questionId,
    this.selectedIndex,
    required this.isCorrect,
    required this.isEmpty,
    required this.correctAnswerIndex,
  });
}

/// Kazanım bazlı istatistik (ham veri).
class OutcomeStatsData {
  final String outcomeId;
  final int total;
  final int correct;
  final int wrong;
  final int empty;
  final double percentage;

  const OutcomeStatsData({
    required this.outcomeId,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.empty,
    required this.percentage,
  });
}

/// Test sonucu hesaplama çıktısı.
class TestResultCalculation {
  final List<CalculatedAnswer> answers;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int emptyAnswers;
  final double successPercentage;
  final Map<String, OutcomeStatsData> outcomeStats;

  const TestResultCalculation({
    required this.answers,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.emptyAnswers,
    required this.successPercentage,
    required this.outcomeStats,
  });
}

/// Test sonuçlarını hesaplayan ortak yardımcı.
/// Paragraf Koçu, Deneme ve Konu testleri için tek kaynak.
class TestResultCalculator {
  TestResultCalculator._();

  /// Sorular ve cevaplardan test sonucunu hesaplar.
  static TestResultCalculation calculate({
    required List<Question> questions,
    required Map<String, int?> answers,
  }) {
    final calculatedAnswers = <CalculatedAnswer>[];
    final outcomeMap = <String, List<CalculatedAnswer>>{};

    for (final question in questions) {
      final selectedIndex = answers[question.id];
      final isCorrect =
          selectedIndex != null && selectedIndex == question.correctAnswerIndex;
      final isEmpty = selectedIndex == null;

      final answer = CalculatedAnswer(
        questionId: question.id,
        selectedIndex: selectedIndex,
        isCorrect: isCorrect,
        isEmpty: isEmpty,
        correctAnswerIndex: question.correctAnswerIndex,
      );
      calculatedAnswers.add(answer);

      final outcomeId = question.learningOutcome?.id ?? 'general';
      outcomeMap.putIfAbsent(outcomeId, () => []).add(answer);
    }

    final totalQuestions = calculatedAnswers.length;
    final correctAnswers =
        calculatedAnswers.where((a) => a.isCorrect).length;
    final wrongAnswers =
        calculatedAnswers.where((a) => !a.isCorrect && !a.isEmpty).length;
    final emptyAnswers =
        calculatedAnswers.where((a) => a.isEmpty).length;
    final successPercentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions) * 100
        : 0.0;

    final outcomeStats = <String, OutcomeStatsData>{};
    for (final entry in outcomeMap.entries) {
      final list = entry.value;
      final total = list.length;
      final correct = list.where((a) => a.isCorrect).length;
      final wrong = list.where((a) => !a.isCorrect && !a.isEmpty).length;
      final empty = list.where((a) => a.isEmpty).length;
      final percentage = total > 0 ? (correct / total) * 100 : 0.0;

      outcomeStats[entry.key] = OutcomeStatsData(
        outcomeId: entry.key,
        total: total,
        correct: correct,
        wrong: wrong,
        empty: empty,
        percentage: percentage,
      );
    }

    return TestResultCalculation(
      answers: calculatedAnswers,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      emptyAnswers: emptyAnswers,
      successPercentage: successPercentage,
      outcomeStats: outcomeStats,
    );
  }

  /// API'den gelen cevap listesini [answers] formatına çevirir.
  static Map<String, int?> answersFromApi(List<dynamic> answersData) {
    final map = <String, int?>{};
    for (final a in answersData) {
      final m = a as Map<String, dynamic>;
      final qId = m['questionId'] as String?;
      if (qId != null) {
        map[qId] = m['selectedIndex'] as int?;
      }
    }
    return map;
  }
}
