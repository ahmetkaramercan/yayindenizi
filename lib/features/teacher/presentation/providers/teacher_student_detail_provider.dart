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

      // Try to load analytics
      StudentAnalysis? analysis;
      try {
        final analyticsData = await _analyticsRepo.getStudentOverview(studentId);
        final sections = analyticsData['sections'] as List? ?? [];
        final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

        for (final section in sections) {
          final s = section as Map<String, dynamic>;
          final outcomes = s['learningOutcomes'] as List? ?? [];

          for (final lo in outcomes) {
            final o = lo as Map<String, dynamic>;
            final id = o['id'] ?? '';
            learningOutcomeProgress[id] = LearningOutcomeProgress(
              learningOutcome: LearningOutcome(
                id: id,
                name: o['name'] ?? '',
              ),
              totalQuestions: o['totalQuestions'] ?? 0,
              completedQuestions: o['completedQuestions'] ?? 0,
              correctAnswers: o['correctAnswers'] ?? 0,
              completionPercentage: _toDouble(o['completionPercentage']),
              successPercentage: _toDouble(o['successPercentage']),
            );
          }
        }

        analysis = StudentAnalysis(
          studentId: studentId,
          learningOutcomeProgress: learningOutcomeProgress,
          totalTestsCompleted: analyticsData['totalTests'] ?? 0,
          overallSuccessPercentage: _toDouble(analyticsData['overallSuccess']),
        );
      } catch (_) {
        // Analytics might not be available yet
      }

      // Try to load test history
      final results = detailData['results'] as List? ?? [];
      final testHistory = results.map((r) {
        final json = r as Map<String, dynamic>;
        return TestHistoryItem(
          id: json['id'] ?? '',
          testTitle: json['test']?['title'] ?? json['testTitle'] ?? '',
          testType: TestType.paragrafKocu,
          totalQuestions: json['totalQuestions'] ?? 0,
          correctAnswers: json['correctAnswers'] ?? 0,
          wrongAnswers: json['wrongAnswers'] ?? 0,
          successPercentage: _toDouble(json['successPercentage']),
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
