import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/auth_repository.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? userRole;

  LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.userRole,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? userRole,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      userRole: userRole ?? this.userRole,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(LoginState());

  final _authRepo = sl<AuthRepository>();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final response = await _authRepo.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        userRole: response.role,
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
    state = LoginState();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
