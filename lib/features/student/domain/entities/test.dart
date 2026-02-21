import 'package:equatable/equatable.dart';
import 'question.dart';

class Test extends Equatable {
  final String id;
  final String title;
  final String? description;
  final List<Question> questions;
  final int level; // 1-8 arası seviye
  final Duration? timeLimit;

  const Test({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
    required this.level,
    this.timeLimit,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        questions,
        level,
        timeLimit,
      ];

  Test copyWith({
    String? id,
    String? title,
    String? description,
    List<Question>? questions,
    int? level,
    Duration? timeLimit,
  }) {
    return Test(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      level: level ?? this.level,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }
}


