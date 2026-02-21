import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../teacher/data/repositories/relation_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class AddTeacherState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  AddTeacherState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddTeacherState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AddTeacherState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AddTeacherNotifier extends StateNotifier<AddTeacherState> {
  AddTeacherNotifier() : super(AddTeacherState());

  final _relationRepo = sl<RelationRepository>();

  Future<void> addTeacher(String teacherCode) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final code = teacherCode.trim().toUpperCase();

      if (code.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Öğretmen kodu boş bırakılamaz',
          isSuccess: false,
        );
        return;
      }

      await _relationRepo.addTeacher(code);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthRepository.extractError(e),
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = AddTeacherState();
  }
}

final addTeacherProvider =
    StateNotifierProvider<AddTeacherNotifier, AddTeacherState>((ref) {
  return AddTeacherNotifier();
});
