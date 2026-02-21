import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? assetImage;
  final BookCategory category;
  final bool isAvailable;
  final bool hasContent;
  final String? route;

  const Book({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.assetImage,
    required this.category,
    this.isAvailable = true,
    this.hasContent = false,
    this.route,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        assetImage,
        category,
        isAvailable,
        hasContent,
        route,
      ];

  Book copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? assetImage,
    BookCategory? category,
    bool? isAvailable,
    bool? hasContent,
    String? route,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      assetImage: assetImage ?? this.assetImage,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      hasContent: hasContent ?? this.hasContent,
      route: route ?? this.route,
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


