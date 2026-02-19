import '../../domain/entities/progress.dart';

class ProgressModel extends Progress {
  const ProgressModel({
    required super.id,
    required super.userId,
    required super.topicId,
    required super.completedQuestions,
    required super.totalQuestions,
    required super.lastStudied,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      topicId: json['topic_id'] as String,
      completedQuestions: json['completed_questions'] as int,
      totalQuestions: json['total_questions'] as int,
      lastStudied: DateTime.parse(json['last_studied'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'topic_id': topicId,
      'completed_questions': completedQuestions,
      'total_questions': totalQuestions,
      'last_studied': lastStudied.toIso8601String(),
    };
  }
}
