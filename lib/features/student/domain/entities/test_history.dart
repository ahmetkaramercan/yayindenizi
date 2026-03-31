import 'package:equatable/equatable.dart';

enum TestType {
  paragrafKocu,
  deneme,
  konu,
}

class TestHistoryItem extends Equatable {
  final String id;
  final String testTitle;
  final String? bookTitle; // Yeni eklendi
  final TestType testType;
  final int? level; // Paragraf Koçu için seviye
  final String? topicTitle; // Konu testi için konu adı
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int? emptyAnswers; // Deneme testleri için
  final double successPercentage;
  final DateTime completedAt;
  final Duration? duration; // İleride kullanılacak

  const TestHistoryItem({
    required this.id,
    required this.testTitle,
    this.bookTitle,
    required this.testType,
    this.level,
    this.topicTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    this.emptyAnswers,
    required this.successPercentage,
    required this.completedAt,
    this.duration,
  });

  @override
  List<Object?> get props => [
        id,
        testTitle,
        bookTitle,
        testType,
        level,
        topicTitle,
        totalQuestions,
        correctAnswers,
        wrongAnswers,
        emptyAnswers,
        successPercentage,
        completedAt,
        duration,
      ];

  String get testTypeDisplayName {
    switch (testType) {
      case TestType.paragrafKocu:
        return 'Paragraf Koçu';
      case TestType.deneme:
        return 'Deneme';
      case TestType.konu:
        return 'Konu';
    }
  }
}
