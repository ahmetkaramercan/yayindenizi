import 'package:equatable/equatable.dart';
import 'question.dart';
import 'topic.dart';

class TopicTest extends Equatable {
  final String id;
  final String title;
  final String? description;
  final Topic topic; // Bu test hangi konuya ait
  final List<Question> questions;

  const TopicTest({
    required this.id,
    required this.title,
    this.description,
    required this.topic,
    required this.questions,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        topic,
        questions,
      ];

  TopicTest copyWith({
    String? id,
    String? title,
    String? description,
    Topic? topic,
    List<Question>? questions,
  }) {
    return TopicTest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      topic: topic ?? this.topic,
      questions: questions ?? this.questions,
    );
  }
}


