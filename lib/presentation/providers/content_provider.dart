import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/topic.dart';
import '../../data/repositories/content_repository_impl.dart';
import 'auth_provider.dart';

final contentRepositoryProvider = Provider<ContentRepositoryImpl>((ref) {
  return ContentRepositoryImpl(ref.watch(supabaseDataSourceProvider));
});

final topicsProvider = FutureProvider.family<List<Topic>, String?>(
  (ref, grade) async {
    return ref.watch(contentRepositoryProvider).getTopics(grade: grade);
  },
);

final topicDetailProvider = FutureProvider.family<Topic, String>(
  (ref, id) async {
    return ref.watch(contentRepositoryProvider).getTopicById(id);
  },
);
