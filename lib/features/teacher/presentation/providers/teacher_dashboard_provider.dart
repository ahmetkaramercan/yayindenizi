import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/domain/entities/teacher.dart';
import '../../../teacher/domain/entities/classroom.dart';
import '../../../../core/di/injection_container.dart';
import '../../../student/data/repositories/user_repository.dart';
import '../../data/repositories/classroom_repository.dart';

class TeacherDashboardState {
  final Teacher? teacher;
  final List<Classroom> classrooms;
  final bool isLoading;
  final String? error;

  TeacherDashboardState({
    this.teacher,
    this.classrooms = const [],
    this.isLoading = false,
    this.error,
  });

  TeacherDashboardState copyWith({
    Teacher? teacher,
    List<Classroom>? classrooms,
    bool? isLoading,
    String? error,
  }) {
    return TeacherDashboardState(
      teacher: teacher ?? this.teacher,
      classrooms: classrooms ?? this.classrooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TeacherDashboardNotifier
    extends StateNotifier<TeacherDashboardState> {
  TeacherDashboardNotifier() : super(TeacherDashboardState()) {
    loadTeacherInfo();
    loadClassrooms();
  }

  final _userRepo = sl<UserRepository>();
  final _classroomRepo = sl<ClassroomRepository>();

  Future<void> loadTeacherInfo() async {
    try {
      final teacher = await _userRepo.getTeacherProfile();
      state = state.copyWith(teacher: teacher);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadClassrooms() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final classrooms = await _classroomRepo.getMyClassrooms();
      state = state.copyWith(classrooms: classrooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addClassroom(String name) async {
    try {
      final classroom = await _classroomRepo.createClassroom(name);
      state = state.copyWith(classrooms: [classroom, ...state.classrooms]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteClassroom(String classroomId) async {
    try {
      await _classroomRepo.deleteClassroom(classroomId);
      final updated = state.classrooms.where((c) => c.id != classroomId).toList();
      state = state.copyWith(classrooms: updated);
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
