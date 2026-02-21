import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/domain/entities/teacher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../teacher/data/repositories/relation_repository.dart';

class StudentDashboardState {
  final List<Teacher> teachers;
  final bool isLoading;
  final String? error;

  StudentDashboardState({
    this.teachers = const [],
    this.isLoading = false,
    this.error,
  });

  StudentDashboardState copyWith({
    List<Teacher>? teachers,
    bool? isLoading,
    String? error,
  }) {
    return StudentDashboardState(
      teachers: teachers ?? this.teachers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StudentDashboardNotifier extends StateNotifier<StudentDashboardState> {
  StudentDashboardNotifier() : super(StudentDashboardState()) {
    loadTeachers();
  }

  final _relationRepo = sl<RelationRepository>();

  Future<void> loadTeachers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final teachers = await _relationRepo.getMyTeachers();

      state = state.copyWith(
        teachers: teachers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeTeacher(String teacherId) async {
    try {
      await _relationRepo.removeTeacher(teacherId);

      final updatedTeachers =
          state.teachers.where((t) => t.id != teacherId).toList();

      state = state.copyWith(teachers: updatedTeachers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final studentDashboardProvider =
    StateNotifierProvider<StudentDashboardNotifier, StudentDashboardState>(
        (ref) {
  return StudentDashboardNotifier();
});
