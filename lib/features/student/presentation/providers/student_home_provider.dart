import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/book.dart';

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

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: API'den öğrenci bilgilerini ve kitapları getir
      await Future.delayed(const Duration(seconds: 1));

      // Simüle edilmiş öğrenci verisi
      final student = const Student(
        id: '1',
        adSoyad: 'Ahmet Yılmaz',
        email: 'ahmet@example.com',
        il: 'İstanbul',
        ilce: 'Kadıköy',
      );

      // Simüle edilmiş kitap listesi
      final books = [
        const Book(
          id: '1',
          title: 'Paragraf Koçu',
          description: 'Paragraf soruları için kapsamlı rehber',
          category: BookCategory.paragraf,
        ),
        const Book(
          id: '2',
          title: 'Türkçe Denemeleri',
          description: 'Türkçe deneme sınavları',
          category: BookCategory.deneme,
        ),
        const Book(
          id: '3',
          title: 'Deneme Kitapları',
          description: 'Genel deneme sınavları',
          category: BookCategory.deneme,
        ),
        const Book(
          id: '4',
          title: 'Konu Kitapları',
          description: 'Detaylı konu anlatımları',
          category: BookCategory.konu,
        ),
        const Book(
          id: '5',
          title: 'Matematik Soru Bankası',
          description: 'Matematik soruları',
          category: BookCategory.other,
        ),
        const Book(
          id: '6',
          title: 'Fen Bilimleri',
          description: 'Fen bilimleri konuları',
          category: BookCategory.other,
        ),
        const Book(
          id: '7',
          title: 'Sosyal Bilgiler',
          description: 'Sosyal bilgiler konuları',
          category: BookCategory.other,
        ),
        const Book(
          id: '8',
          title: 'İngilizce',
          description: 'İngilizce konuları',
          category: BookCategory.other,
        ),
      ];

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


