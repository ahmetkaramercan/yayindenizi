import '../../../../core/network/api_client.dart';
import '../../domain/entities/book.dart';

class BookRepository {
  final ApiClient _api;

  BookRepository(this._api);

  Future<List<Book>> getBooks({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;

    final data = await _api.get('/books', queryParameters: params);
    final list = data is List ? data : (data as Map)['data'] ?? [];

    return (list as List).map((json) => _bookFromJson(json)).toList();
  }

  Future<Book> getBook(String id) async {
    final data = await _api.get('/books/$id');
    return _bookFromJson(data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getBookSections(String bookId) async {
    final data = await _api.get('/books/$bookId');
    final map = data as Map<String, dynamic>;
    final sections = map['sections'] as List? ?? [];
    return sections.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getSectionTests(String sectionId) async {
    final data = await _api.get('/sections/$sectionId');
    final map = data as Map<String, dynamic>;
    final tests = map['tests'] as List? ?? [];
    return tests.cast<Map<String, dynamic>>();
  }

  Book _bookFromJson(Map<String, dynamic> json) {
    final rawImagePath = json['imageUrl'] as String?;
    String? assetImage;
    String? networkImageUrl;
    if (rawImagePath != null && rawImagePath.isNotEmpty) {
      if (rawImagePath.startsWith('http://') ||
          rawImagePath.startsWith('https://')) {
        networkImageUrl = rawImagePath;
      } else if (rawImagePath.startsWith('assets/') ||
          rawImagePath.startsWith('photos/')) {
        assetImage = rawImagePath;
      } else {
        assetImage = 'assets/images/books/$rawImagePath';
      }
    }

    final sections = json['sections'] as List? ?? [];
    final hasTests = sections.any((s) {
      final count = s['_count']?['tests'] ?? (s['tests'] as List?)?.length ?? 0;
      return count > 0;
    });

    return Book(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: networkImageUrl,
      assetImage: assetImage,
      category: _parseCategory(json['category']),
      hasContent: hasTests,
      route: hasTests ? '/student/book-detail' : null,
    );
  }

  BookCategory _parseCategory(String? category) {
    switch (category) {
      case 'PARAGRAF':
        return BookCategory.paragraf;
      case 'DENEME':
        return BookCategory.deneme;
      case 'KONU':
        return BookCategory.konu;
      default:
        return BookCategory.other;
    }
  }
}
