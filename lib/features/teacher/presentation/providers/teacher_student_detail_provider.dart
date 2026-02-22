import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_analysis.dart';
import '../../../student/domain/entities/test_history.dart';
import '../../../student/domain/entities/learning_outcome.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/relation_repository.dart';
import '../../../student/data/repositories/analytics_repository.dart';
import 'teacher_dashboard_provider.dart';

class TeacherStudentDetailState {
  final Student? student;
  final StudentAnalysis? analysis;
  final List<TestHistoryItem> testHistory;
  final bool isLoading;
  final String? error;

  TeacherStudentDetailState({
    this.student,
    this.analysis,
    this.testHistory = const [],
    this.isLoading = false,
    this.error,
  });

  TeacherStudentDetailState copyWith({
    Student? student,
    StudentAnalysis? analysis,
    List<TestHistoryItem>? testHistory,
    bool? isLoading,
    String? error,
  }) {
    return TeacherStudentDetailState(
      student: student ?? this.student,
      analysis: analysis ?? this.analysis,
      testHistory: testHistory ?? this.testHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TeacherStudentDetailNotifier
    extends StateNotifier<TeacherStudentDetailState> {
  final String studentId;
  final Ref ref;

  TeacherStudentDetailNotifier(this.studentId, this.ref)
      : super(TeacherStudentDetailState()) {
    loadData();
  }

  final _relationRepo = sl<RelationRepository>();
  final _analyticsRepo = sl<AnalyticsRepository>();

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final detailData = await _relationRepo.getStudentDetail(studentId);

      final studentJson = detailData['student'] as Map<String, dynamic>? ?? detailData;
      final student = Student(
        id: studentJson['id'] ?? studentId,
        adSoyad: studentJson['adSoyad'] ?? '',
        email: studentJson['email'] ?? '',
        il: studentJson['il'],
        ilce: studentJson['ilce'],
      );

      // Try to load analytics (getStudentFull = kazanım verileri dahil)
      StudentAnalysis? analysis;
      try {
        final analyticsData = await _analyticsRepo.getStudentFull(studentId);
        final rawOutcomes = analyticsData['learningOutcomes'] as List? ??
            analyticsData['learningOutcomeStats'] as List? ??
            [];
        final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

        for (final lo in rawOutcomes) {
          final o = lo as Map<String, dynamic>;
          final id = o['id'] ?? o['learningOutcomeId'] ?? '';
          if (id.isEmpty) continue;

          learningOutcomeProgress[id] = LearningOutcomeProgress(
            learningOutcome: LearningOutcome(
              id: id,
              name: o['name'] ?? o['learningOutcomeName'] ?? '',
              description: o['description']?.toString(),
            ),
            totalQuestions: (o['totalQuestions'] ?? 0) as int,
            completedQuestions:
                (o['completedQuestions'] ?? o['totalQuestions'] ?? 0) as int,
            correctAnswers: (o['correctAnswers'] ?? 0) as int,
            incorrectAnswers: (o['incorrectAnswers'] ?? 0) as int,
            completionPercentage: _toDouble(o['completionPercentage'] ?? 100),
            successPercentage:
                _toDouble(o['successPercentage'] ?? o['accuracy'] ?? 0),
          );
        }

        final overview = analyticsData['overview'] as Map<String, dynamic>?;
        final totalTests =
            analyticsData['totalTests'] ?? overview?['totalTests'] ?? 0;
        final overallSuccess =
            analyticsData['overallSuccess'] ?? overview?['overallAccuracy'] ?? 0;
        final totalCorrect =
            analyticsData['totalCorrect'] ?? overview?['totalCorrect'] ?? 0;
        final totalIncorrect =
            analyticsData['totalIncorrect'] ?? overview?['totalIncorrect'] ?? 0;

        analysis = StudentAnalysis(
          studentId: studentId,
          learningOutcomeProgress: learningOutcomeProgress,
          totalTestsCompleted: totalTests as int,
          overallSuccessPercentage: _toDouble(overallSuccess),
          totalCorrect: totalCorrect as int,
          totalIncorrect: totalIncorrect as int,
        );
      } catch (_) {
        // Analytics might not be available yet
      }

      // Try to load test history
      final results = detailData['results'] as List? ?? [];
      final testHistory = results.map((r) {
        final json = r as Map<String, dynamic>;
        final answers = json['answers'] as List? ?? [];
        final totalQuestions = answers.length;
        final correctAnswers =
            answers.where((a) => (a as Map<String, dynamic>)['isCorrect'] == true).length;
        final wrongAnswers = answers.where((a) {
          final m = a as Map<String, dynamic>;
          return m['isCorrect'] != true && m['selectedIndex'] != null;
        }).length;
        final emptyAnswers = totalQuestions - correctAnswers - wrongAnswers;

        return TestHistoryItem(
          id: json['id'] ?? '',
          testTitle: json['test']?['title'] ?? json['testTitle'] ?? '',
          testType: TestType.paragrafKocu,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          emptyAnswers: emptyAnswers,
          successPercentage: _toDouble(json['score']),
          completedAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        );
      }).toList();

      state = state.copyWith(
        student: student,
        analysis: analysis,
        testHistory: testHistory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeStudent(String studentId) async {
    try {
      await _relationRepo.removeStudent(studentId);
      ref.read(teacherDashboardProvider.notifier).removeStudent(studentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return 0.0;
  }
}

final teacherStudentDetailProvider =
    StateNotifierProvider.family<TeacherStudentDetailNotifier,
        TeacherStudentDetailState, String>((ref, studentId) {
  return TeacherStudentDetailNotifier(studentId, ref);
});
