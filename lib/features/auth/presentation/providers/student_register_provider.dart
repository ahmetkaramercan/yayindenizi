import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/auth_repository.dart';

class StudentRegisterState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  StudentRegisterState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  StudentRegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return StudentRegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class StudentRegisterNotifier extends StateNotifier<StudentRegisterState> {
  StudentRegisterNotifier() : super(StudentRegisterState());

  final _authRepo = sl<AuthRepository>();

  Future<void> register({
    required String adSoyad,
    required String email,
    required String password,
    String? cityId,
    String? districtId,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _authRepo.registerStudent(
        email: email,
        password: password,
        adSoyad: adSoyad,
        cityId: cityId,
        districtId: districtId,
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
    state = StudentRegisterState();
  }
}

final studentRegisterProvider =
    StateNotifierProvider<StudentRegisterNotifier, StudentRegisterState>((ref) {
  return StudentRegisterNotifier();
});
