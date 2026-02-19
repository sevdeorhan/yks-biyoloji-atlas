import '../entities/progress.dart';

abstract class ProgressRepository {
  Future<List<Progress>> getUserProgress(String userId);
  Future<Progress?> getTopicProgress(String userId, String topicId);
  Future<void> updateProgress(Progress progress);
}
