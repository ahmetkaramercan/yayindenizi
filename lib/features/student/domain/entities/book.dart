import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final BookCategory category;
  final bool isAvailable;

  const Book({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.category,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        category,
        isAvailable,
      ];

  Book copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    BookCategory? category,
    bool? isAvailable,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

enum BookCategory {
  paragraf,
  deneme,
  konu,
  other,
}

extension BookCategoryExtension on BookCategory {
  String get displayName {
    switch (this) {
      case BookCategory.paragraf:
        return 'Paragraf';
      case BookCategory.deneme:
        return 'Deneme';
      case BookCategory.konu:
        return 'Konu';
      case BookCategory.other:
        return 'Diğer';
    }
  }
}


