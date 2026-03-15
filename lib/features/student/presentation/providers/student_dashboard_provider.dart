import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/domain/entities/classroom.dart';
import '../../../../core/di/injection_container.dart';
import '../../../teacher/data/repositories/classroom_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class StudentDashboardState {
  final List<Classroom> classrooms;
  final bool isLoading;
  final String? error;

  StudentDashboardState({
    this.classrooms = const [],
    this.isLoading = false,
    this.error,
  });

  StudentDashboardState copyWith({
    List<Classroom>? classrooms,
    bool? isLoading,
    String? error,
  }) {
    return StudentDashboardState(
      classrooms: classrooms ?? this.classrooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StudentDashboardNotifier extends StateNotifier<StudentDashboardState> {
  StudentDashboardNotifier() : super(StudentDashboardState()) {
    loadClassrooms();
  }

  final _classroomRepo = sl<ClassroomRepository>();

  Future<void> loadClassrooms() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final classrooms = await _classroomRepo.getStudentClassrooms();
      state = state.copyWith(classrooms: classrooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: AuthRepository.extractError(e));
    }
  }

  Future<void> leaveClassroom(String classroomId) async {
    try {
      await _classroomRepo.leaveClassroom(classroomId);
      final updated = state.classrooms.where((c) => c.id != classroomId).toList();
      state = state.copyWith(classrooms: updated);
    } catch (e) {
      state = state.copyWith(error: AuthRepository.extractError(e));
    }
  }
}

final studentDashboardProvider =
    StateNotifierProvider<StudentDashboardNotifier, StudentDashboardState>(
        (ref) {
  return StudentDashboardNotifier();
});
