import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/test.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/test_repository.dart';

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

  final _testRepo = sl<TestRepository>();
  String? _bookId;

  void setBookId(String bookId) {
    if (_bookId != bookId) {
      _bookId = bookId;
      loadTests();
    }
  }

  Future<void> loadTests() async {
    if (_bookId == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sections = await _testRepo.getSections(_bookId!);

      final allTests = <Test>[];
      for (final section in sections) {
        final tests = await _testRepo.getTestsBySection(section.id);
        allTests.addAll(tests);
      }

      state = state.copyWith(
        tests: allTests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
