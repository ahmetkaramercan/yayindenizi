import '../../features/student/domain/entities/book.dart';

class BookUtils {
  static void sortBooks(List<Book> books) {
    books.sort((a, b) {
      int indexA = getBookOrderIndex(a.title);
      int indexB = getBookOrderIndex(b.title);

      if (indexA != indexB) {
        return indexA.compareTo(indexB);
      }

      if (a.hasContent && !b.hasContent) return -1;
      if (!a.hasContent && b.hasContent) return 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
  }

  static int getBookOrderIndex(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('hafta esaslı')) return 0;
    if (lowerTitle.contains('paragraf koçu denemeleri') ||
        lowerTitle == 'paragraf koçu') return 1;
    if (lowerTitle.contains('3g1k') ||
        lowerTitle.contains('türkçe soru bankası')) return 2;
    if (lowerTitle.contains('türkçe denemeleri')) return 3;
    if (lowerTitle.contains('edebiyat soru bankası')) return 4;
    if (lowerTitle.contains('edebiyat denemeleri')) return 5;
    if (lowerTitle.contains('dil bilgisi soru bankası')) return 6;
    if (lowerTitle.contains('dil bilgisi denemeleri')) return 7;

    return 100; // Put unknown books at the end
  }
}
