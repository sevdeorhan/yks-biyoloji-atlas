import '../entities/topic.dart';

abstract class ContentRepository {
  Future<List<Topic>> getTopics({String? grade});
  Future<Topic> getTopicById(String id);
}
