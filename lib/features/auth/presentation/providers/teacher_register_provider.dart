import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherRegisterState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  TeacherRegisterState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  TeacherRegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return TeacherRegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class TeacherRegisterNotifier extends StateNotifier<TeacherRegisterState> {
  TeacherRegisterNotifier() : super(TeacherRegisterState());

  Future<void> register({
    required String adSoyad,
    required String email,
    required String password,
    String? il,
    String? ilce,
    String? okul,
    required String ogretmenKodu,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      // TODO: API çağrısı yapılacak
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş API çağrısı

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = TeacherRegisterState();
  }
}

final teacherRegisterProvider =
    StateNotifierProvider<TeacherRegisterNotifier, TeacherRegisterState>((ref) {
  return TeacherRegisterNotifier();
});

