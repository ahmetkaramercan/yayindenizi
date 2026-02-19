import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_analysis.dart';
import '../../../student/domain/entities/test_history.dart';
import '../../../../core/constants/learning_outcomes.dart';
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

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den öğrenci detayını, analizini ve test geçmişini getir
      await Future.delayed(const Duration(seconds: 1));

      // Öğrenci bilgisini dashboard'dan al
      final dashboardState = ref.read(teacherDashboardProvider);
      final student = dashboardState.students.firstWhere(
        (s) => s.id == studentId,
        orElse: () => dashboardState.students.first,
      );

      // Simüle edilmiş analiz verisi
      final allOutcomes = AppLearningOutcomes.getAll();
      final learningOutcomeProgress = <String, LearningOutcomeProgress>{};

      for (final outcome in allOutcomes) {
        final totalQuestions = 20;
        final completedQuestions = (totalQuestions * 0.6).toInt();
        final correctAnswers = (completedQuestions * 0.75).toInt();
        final completionPercentage =
            (completedQuestions / totalQuestions) * 100;
        final successPercentage = completedQuestions > 0
            ? (correctAnswers / completedQuestions) * 100
            : 0.0;

        learningOutcomeProgress[outcome.id] = LearningOutcomeProgress(
          learningOutcome: outcome,
          totalQuestions: totalQuestions,
          completedQuestions: completedQuestions,
          correctAnswers: correctAnswers,
          completionPercentage: completionPercentage,
          successPercentage: successPercentage,
        );
      }

      final analysis = StudentAnalysis(
        studentId: studentId,
        learningOutcomeProgress: learningOutcomeProgress,
        totalTestsCompleted: 15,
        overallSuccessPercentage: 72.5,
      );

      // Simüle edilmiş test geçmişi
      final testHistory = [
        TestHistoryItem(
          id: 'history_1',
          testTitle: 'Paragraf Koçu - Seviye 3',
          testType: TestType.paragrafKocu,
          level: 3,
          totalQuestions: 10,
          correctAnswers: 8,
          wrongAnswers: 2,
          successPercentage: 80.0,
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TestHistoryItem(
          id: 'history_2',
          testTitle: 'Deneme Testi 1',
          testType: TestType.deneme,
          totalQuestions: 20,
          correctAnswers: 14,
          wrongAnswers: 4,
          emptyAnswers: 2,
          successPercentage: 70.0,
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        TestHistoryItem(
          id: 'history_3',
          testTitle: 'Paragraf Analizi - Test 1',
          testType: TestType.konu,
          topicTitle: 'Paragraf Analizi',
          totalQuestions: 10,
          correctAnswers: 7,
          wrongAnswers: 3,
          successPercentage: 70.0,
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

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
      // TODO: API'ye öğrenciyi silme isteği gönder
      await Future.delayed(const Duration(milliseconds: 500));

      // Dashboard'dan öğrenciyi kaldır
      ref.read(teacherDashboardProvider.notifier).removeStudent(studentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final teacherStudentDetailProvider =
    StateNotifierProvider.family<TeacherStudentDetailNotifier,
        TeacherStudentDetailState, String>((ref, studentId) {
  return TeacherStudentDetailNotifier(studentId, ref);
});


