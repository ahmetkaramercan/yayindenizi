import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/domain/entities/teacher.dart';

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

  Future<void> loadTeachers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den öğrencinin bağlı öğretmenlerini getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş veri
      final teachers = <Teacher>[];

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
      // TODO: API'ye öğretmeni silme isteği gönder
      await Future.delayed(const Duration(milliseconds: 500));

      // Listeden kaldır
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

