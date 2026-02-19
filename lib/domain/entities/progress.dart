class Progress {
  final String id;
  final String userId;
  final String topicId;
  final int completedQuestions;
  final int totalQuestions;
  final DateTime lastStudied;

  const Progress({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.completedQuestions,
    required this.totalQuestions,
    required this.lastStudied,
  });

  double get percentage =>
      totalQuestions > 0 ? completedQuestions / totalQuestions : 0.0;
}
