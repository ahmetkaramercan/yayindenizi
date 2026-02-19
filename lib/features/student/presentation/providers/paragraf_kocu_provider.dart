import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/test.dart';

class ParagrafKocuState {
  final List<Test> tests;
  final bool isLoading;
  final String? error;

  ParagrafKocuState({
    this.tests = const [],
    this.isLoading = false,
    this.error,
  });

  ParagrafKocuState copyWith({
    List<Test>? tests,
    bool? isLoading,
    String? error,
  }) {
    return ParagrafKocuState(
      tests: tests ?? this.tests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final paragrafKocuProvider =
    StateNotifierProvider<ParagrafKocuNotifier, ParagrafKocuState>((ref) {
  return ParagrafKocuNotifier();
});

class ParagrafKocuNotifier extends StateNotifier<ParagrafKocuState> {
  ParagrafKocuNotifier() : super(ParagrafKocuState());
}


