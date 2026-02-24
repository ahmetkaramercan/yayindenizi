import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/auth_repository.dart';

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

  final _authRepo = sl<AuthRepository>();

  Future<void> register({
    required String adSoyad,
    required String email,
    required String password,
    required String cityId,
    required String districtId,
    String? okul,
    required String ogretmenKodu,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _authRepo.registerTeacher(
        email: email,
        password: password,
        adSoyad: adSoyad,
        cityId: cityId,
        districtId: districtId,
        okul: okul ?? '',
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthRepository.extractError(e),
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
