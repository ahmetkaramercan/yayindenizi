import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/domain/entities/teacher.dart';
import '../../../student/domain/entities/student.dart';

class TeacherDashboardState {
  final Teacher? teacher;
  final List<Student> students;
  final bool isLoading;
  final String? error;

  TeacherDashboardState({
    this.teacher,
    this.students = const [],
    this.isLoading = false,
    this.error,
  });

  TeacherDashboardState copyWith({
    Teacher? teacher,
    List<Student>? students,
    bool? isLoading,
    String? error,
  }) {
    return TeacherDashboardState(
      teacher: teacher ?? this.teacher,
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TeacherDashboardNotifier
    extends StateNotifier<TeacherDashboardState> {
  TeacherDashboardNotifier() : super(TeacherDashboardState()) {
    loadTeacherInfo();
    loadStudents();
  }

  Future<void> loadTeacherInfo() async {
    try {
      // TODO: API'den öğretmen bilgilerini getir
      await Future.delayed(const Duration(milliseconds: 500));

      // Simüle edilmiş veri
      // state = state.copyWith(teacher: teacher);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadStudents() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den öğretmene bağlı öğrencileri getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş veri
      final students = <Student>[];

      state = state.copyWith(
        students: students,
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

      // Listeden kaldır
      final updatedStudents = state.students
          .where((s) => s.id != studentId)
          .toList();

      state = state.copyWith(students: updatedStudents);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final teacherDashboardProvider =
    StateNotifierProvider<TeacherDashboardNotifier, TeacherDashboardState>(
        (ref) {
  return TeacherDashboardNotifier();
});

