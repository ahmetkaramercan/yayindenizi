import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> register({
    required String adSoyad,
    required String email,
    required String password,
    String? il,
    String? ilce,
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
    state = StudentRegisterState();
  }
}

final studentRegisterProvider =
    StateNotifierProvider<StudentRegisterNotifier, StudentRegisterState>((ref) {
  return StudentRegisterNotifier();
});

