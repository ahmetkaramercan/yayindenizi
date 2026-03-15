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

      const orderedTitles = [
        'Paragraf Koçu Soru Bankası',
        'Paragraf Koçu (Hafta Esaslı)',
        'Paragraf Koçu Denemeleri',
        '3g1k Türkçe Soru Bankası',
        'Türkçe Soru Bankası',
        'Türkçe denemeleri',
        'TYT Türkçe Denemeleri',
        'Edebiyat soru bankası',
        'Edebiyat Soru Bankası',
        'Edebiyat denemeleri',
        'Edebiyat Denemeleri',
        'Dil bilgisi soru bankası',
        'Dil Bilgisi Soru Bankası',
        'Dil bilgisi denemeleri',
        'Dil Bilgisi Denemeleri',
      ];

      int getOrderIndex(String title) {
        final lowerTitle = title.toLowerCase();

        if (lowerTitle.contains('hafta esaslı')) return 0;
        if (lowerTitle.contains('paragraf koçu denemeleri') ||
            lowerTitle == 'paragraf koçu') return 1;
        if (lowerTitle.contains('türkçe soru bankası')) return 2;
        if (lowerTitle.contains('türkçe denemeleri')) return 3;
        if (lowerTitle.contains('edebiyat soru bankası')) return 4;
        if (lowerTitle.contains('edebiyat denemeleri')) return 5;
        if (lowerTitle.contains('dil bilgisi soru bankası')) return 6;
        if (lowerTitle.contains('dil bilgisi denemeleri')) return 7;

        // Try exact match with orderedTitles list as a fallback
        int index =
            orderedTitles.indexWhere((t) => t.toLowerCase() == lowerTitle);
        if (index != -1) return index;

        return 100; // Put unknown books at the end
      }

      books.sort((a, b) {
        int indexA = getOrderIndex(a.title);
        int indexB = getOrderIndex(b.title);

        if (indexA != indexB) {
          return indexA.compareTo(indexB);
        }

        // Fallback to hasContent sorting if same index or unknown
        if (a.hasContent && !b.hasContent) return -1;
        if (!a.hasContent && b.hasContent) return 1;
        return a.title.compareTo(b.title);
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
