import '../../../../core/network/api_client.dart';
import '../../domain/entities/test.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/learning_outcome.dart';
import '../../domain/entities/topic.dart';

class TestRepository {
  final ApiClient _api;

  TestRepository(this._api);

  // ─── Sections (Topics in frontend) ────────────────────────────────────

  Future<List<Topic>> getSections(String bookId) async {
    final data = await _api.get('/books/$bookId');
    final map = data as Map<String, dynamic>;
    final sections = map['sections'] as List? ?? [];

    return sections.map((json) {
      final j = json as Map<String, dynamic>;
      return Topic(
        id: j['id'],
        title: j['title'],
        description: j['description'] ?? '',
        testCount: j['_count']?['tests'] ?? (j['tests'] as List?)?.length ?? 0,
      );
    }).toList();
  }

  Future<Topic> getSection(String sectionId) async {
    final data = await _api.get('/sections/$sectionId');
    final map = data as Map<String, dynamic>;
    final tests = map['tests'] as List? ?? [];

    return Topic(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      testCount: tests.length,
    );
  }

  // ─── Tests ─────────────────────────────────────────────────────────────

  Future<List<Test>> getTestsBySection(String sectionId) async {
    final data = await _api.get('/sections/$sectionId');
    final map = data as Map<String, dynamic>;
    final tests = map['tests'] as List? ?? [];

    return tests.map((json) {
      final j = json as Map<String, dynamic>;
      return Test(
        id: j['id'],
        title: j['title'],
        description: j['description'] ?? '',
        questions: const [],
        level: j['level'] ?? 1,
        timeLimit: j['timeLimit'] != null && j['timeLimit'] > 0
            ? Duration(seconds: j['timeLimit'])
            : null,
      );
    }).toList();
  }

  Future<Test> getTest(String testId) async {
    final data = await _api.get('/tests/$testId');
    final map = data as Map<String, dynamic>;
    final questions = (map['questions'] as List? ?? [])
        .map((q) => _questionFromJson(q as Map<String, dynamic>))
        .toList();

    return Test(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      questions: questions,
      level: map['level'] ?? 1,
      timeLimit: map['timeLimit'] != null && map['timeLimit'] > 0
          ? Duration(seconds: map['timeLimit'])
          : null,
    );
  }

  // ─── Results ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitResult({
    required String testId,
    required List<Map<String, dynamic>> answers,
    required int totalTime,
  }) async {
    final data = await _api.post('/results', data: {
      'testId': testId,
      'answers': answers,
      'totalTime': totalTime,
    });
    return data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyResults() async {
    final data = await _api.get('/results/my/history');
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>?> getResultForTest(String testId) async {
    final data = await _api.get('/results/my', queryParameters: {'testId': testId});
    if (data is List && data.isNotEmpty) {
      return data.first as Map<String, dynamic>;
    }
    return null;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  Question _questionFromJson(Map<String, dynamic> q) {
    var lo = q['learningOutcome'] as Map<String, dynamic>?;
    if (lo == null) {
      final qoList = q['questionOutcomes'] as List?;
      if (qoList != null && qoList.isNotEmpty) {
        final first = qoList.first as Map<String, dynamic>;
        lo = first['learningOutcome'] as Map<String, dynamic>?;
      }
    }
    return Question(
      id: q['id'],
      text: q['text'] ?? '',
      options: [
        q['optionA'] ?? 'A',
        q['optionB'] ?? 'B',
        q['optionC'] ?? 'C',
        q['optionD'] ?? 'D',
        q['optionE'] ?? 'E',
      ],
      correctAnswerIndex: q['correctAnswerIndex'] ?? 0,
      learningOutcome: lo != null
          ? LearningOutcome(
              id: lo['id'],
              name: lo['name'] ?? '',
              description: lo['description'],
            )
          : null,
      explanation: q['explanation'],
      videoUrl: q['videoUrl'],
    );
  }
}
