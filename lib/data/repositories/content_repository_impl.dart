import '../../domain/entities/topic.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../../core/errors/exceptions.dart';

class ContentRepositoryImpl implements ContentRepository {
  final SupabaseDataSource _remote;

  ContentRepositoryImpl(this._remote);

  @override
  Future<List<Topic>> getTopics({String? grade}) async {
    return _remote.getTopics(grade: grade);
  }

  @override
  Future<Topic> getTopicById(String id) async {
    final topics = await _remote.getTopics();
    final topic = topics.where((t) => t.id == id).firstOrNull;
    if (topic == null) throw const ServerException('Konu bulunamadı');
    return topic;
  }
}
