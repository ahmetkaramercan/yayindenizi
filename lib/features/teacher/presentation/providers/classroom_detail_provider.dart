import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../teacher/domain/entities/classroom.dart';
import '../../../student/domain/entities/student.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/classroom_repository.dart';
import '../../../teacher/data/models/classroom_model.dart';

class ClassroomDetailState {
  final Classroom? classroom;
  final List<Student> students;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;

  ClassroomDetailState({
    this.classroom,
    this.students = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
  });

  ClassroomDetailState copyWith({
    Classroom? classroom,
    List<Student>? students,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
  }) {
    return ClassroomDetailState(
      classroom: classroom ?? this.classroom,
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
    );
  }
}

class ClassroomDetailNotifier
    extends StateNotifier<ClassroomDetailState> {
  final String classroomId;

  ClassroomDetailNotifier(this.classroomId)
      : super(ClassroomDetailState()) {
    loadDetail();
  }

  final _classroomRepo = sl<ClassroomRepository>();

  Future<void> loadDetail({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _classroomRepo.getClassroomDetail(
        classroomId,
        search: search,
      );

      final classroomJson = data['classroom'] as Map<String, dynamic>;
      final classroom = ClassroomModel.fromJson(classroomJson);

      final studentList = data['students'] as List? ?? [];
      final students = studentList.map((s) {
        final j = s as Map<String, dynamic>;
        final city = j['city'] as Map<String, dynamic>?;
        final district = j['district'] as Map<String, dynamic>?;
        return Student(
          id: j['id'],
          adSoyad: j['adSoyad'] ?? '',
          email: j['email'] ?? '',
          cityId: j['cityId'],
          districtId: j['districtId'],
          cityName: city?['name'],
          districtName: district?['name'],
        );
      }).toList();

      state = state.copyWith(
        classroom: classroom,
        students: students,
        total: (data['total'] ?? 0) as int,
        page: (data['page'] ?? 1) as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeStudent(String studentId) async {
    try {
      await _classroomRepo.removeStudentFromClassroom(classroomId, studentId);
      final updated = state.students.where((s) => s.id != studentId).toList();
      final newTotal = state.total > 0 ? state.total - 1 : 0;
      state = state.copyWith(
        students: updated,
        total: newTotal,
        classroom: state.classroom?.copyWith(studentCount: newTotal),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final classroomDetailProvider =
    StateNotifierProvider.family<ClassroomDetailNotifier, ClassroomDetailState, String>(
        (ref, classroomId) {
  return ClassroomDetailNotifier(classroomId);
});
