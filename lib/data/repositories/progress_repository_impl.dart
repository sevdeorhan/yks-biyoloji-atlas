import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../datasources/local/hive_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final SupabaseDataSource _remote;
  final HiveDataSource _local;

  ProgressRepositoryImpl(this._remote, this._local);

  @override
  Future<List<Progress>> getUserProgress(String userId) async {
    return _remote.getUserProgress(userId);
  }

  @override
  Future<Progress?> getTopicProgress(String userId, String topicId) async {
    final allProgress = await _remote.getUserProgress(userId);
    return allProgress.where((p) => p.topicId == topicId).firstOrNull;
  }

  @override
  Future<void> updateProgress(Progress progress) async {
    await _local.saveProgress(
      '${progress.userId}_${progress.topicId}',
      {
        'id': progress.id,
        'user_id': progress.userId,
        'topic_id': progress.topicId,
        'completed_questions': progress.completedQuestions,
        'total_questions': progress.totalQuestions,
        'last_studied': progress.lastStudied.toIso8601String(),
      },
    );
  }
}
