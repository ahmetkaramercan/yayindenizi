import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/teacher_code_generator.dart';

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

  Future<void> addTeacher(String teacherCode) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      // Kodu formatla ve kontrol et
      final formattedCode = TeacherCodeGenerator.format(teacherCode);
      
      if (!TeacherCodeGenerator.isValid(formattedCode)) {
        state = state.copyWith(
          isLoading: false,
          error: 'Geçersiz öğretmen kodu formatı. Format: TCH123456',
          isSuccess: false,
        );
        return;
      }

      // TODO: API çağrısı - öğretmen koduna göre öğretmeni bul ve öğrenciye ekle
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş başarı
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
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


