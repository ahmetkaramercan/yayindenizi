import 'package:equatable/equatable.dart';
import 'question.dart';

class MockTest extends Equatable {
  final String id;
  final String title;
  final String? description;
  final List<Question> questions;
  final Duration? timeLimit; // İleride kullanılacak
  final DateTime? createdAt;

  const MockTest({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
    this.timeLimit,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        questions,
        timeLimit,
        createdAt,
      ];

  MockTest copyWith({
    String? id,
    String? title,
    String? description,
    List<Question>? questions,
    Duration? timeLimit,
    DateTime? createdAt,
  }) {
    return MockTest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      timeLimit: timeLimit ?? this.timeLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


