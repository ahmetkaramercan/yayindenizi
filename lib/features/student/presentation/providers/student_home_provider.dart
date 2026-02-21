import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/book.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/book_repository.dart';

class StudentHomeState {
  final Student? student;
  final List<Book> books;
  final bool isLoading;
  final String? error;

  StudentHomeState({
    this.student,
    this.books = const [],
    this.isLoading = false,
    this.error,
  });

  StudentHomeState copyWith({
    Student? student,
    List<Book>? books,
    bool? isLoading,
    String? error,
  }) {
    return StudentHomeState(
      student: student ?? this.student,
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StudentHomeNotifier extends StateNotifier<StudentHomeState> {
  StudentHomeNotifier() : super(StudentHomeState()) {
    loadData();
  }

  final _userRepo = sl<UserRepository>();
  final _bookRepo = sl<BookRepository>();

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _userRepo.getStudentProfile(),
        _bookRepo.getBooks(),
      ]);

      final student = results[0] as Student;
      final books = results[1] as List<Book>;

      books.sort((a, b) {
        if (a.hasContent && !b.hasContent) return -1;
        if (!a.hasContent && b.hasContent) return 1;
        return 0;
      });

      state = state.copyWith(
        student: student,
        books: books,
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

final studentHomeProvider =
    StateNotifierProvider<StudentHomeNotifier, StudentHomeState>((ref) {
  return StudentHomeNotifier();
});
