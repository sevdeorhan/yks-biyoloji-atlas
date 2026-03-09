import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// İleride veritabanından (Supabase/Hive vb.) gelecek olan ilerleme veri modeli
class ProgressData {
  final int completedTopics;
  final int solvedQuestions;
  final int streakDays;
  final List<TopicProgress> topicProgresses;
  final List<UserBadge> earnedBadges;
  final List<UserBadge> allBadges;

  ProgressData({
    required this.completedTopics,
    required this.solvedQuestions,
    required this.streakDays,
    required this.topicProgresses,
    required this.earnedBadges,
    required this.allBadges,
  });
}

// Kazanılan rozetleri (başarıları) tutan alt model
class UserBadge {
  final String id;
  final String title;
  final String description;
  final String
      iconPath; // veya IconData kullanılabilir, esneklik için string tuttuk

  UserBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
  });
}

// Konu bazlı ilerleme detaylarını tutan alt model
class TopicProgress {
  final String title;
  final double progress;
  final int solvedQuestions;

  TopicProgress({
    required this.title,
    required this.progress,
    required this.solvedQuestions,
  });
}

// Tüm mümkün rozetleri tanımlayan sabit liste
final List<UserBadge> allAvailableBadges = [
  UserBadge(
    id: '1',
    title: 'İlk Adım',
    description: 'Uygulamaya ilk giriş.',
    iconPath: '🏃',
  ),
  UserBadge(
    id: '2',
    title: '7 Gün Serisi',
    description: 'Aralıksız 7 gün çalıştın.',
    iconPath: '🔥',
  ),
  UserBadge(
    id: '3',
    title: 'Hücre Uzmanı',
    description: 'Hücre konusunu %100 tamamladın.',
    iconPath: '🔬',
  ),
  UserBadge(
    id: '4',
    title: 'Soru Canavarı',
    description: '1000\'den fazla soru çözdün.',
    iconPath: '👾',
  ),
  UserBadge(
    id: '5',
    title: 'Gece Kuşu',
    description: 'Gece yarısından sonra test çözdün.',
    iconPath: '🦉',
  ),
  UserBadge(
    id: '6',
    title: 'Hatasız Kul Olmaz',
    description: 'Bir testi hiç yanlış yapmadan tamamladın.',
    iconPath: '🎯',
  ),
  UserBadge(
    id: '7',
    title: '3 Gün Serisi',
    description: 'Aralıksız 3 gün çalıştın.',
    iconPath: '🥉',
  ),
  UserBadge(
    id: '8',
    title: '14 Gün Serisi',
    description: 'Aralıksız 14 gün çalıştın.',
    iconPath: '🥈',
  ),
  UserBadge(
    id: '9',
    title: '30 Gün Serisi',
    description: 'Aralıksız 30 gün çalıştın!',
    iconPath: '🏆',
  ),
];

// Şimdilik uygulamanın içinde sabit duracak, ama her yerden erişilebilecek
// Mock (sahte) verilerimizi sağlayan Provider'ımız.
// İlerde Supabase'i bağladığımızda burası 'FutureProvider' veya 'AsyncNotifier' olacak.
final progressProvider = FutureProvider<ProgressData>((ref) async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      // Supabase'den verileri çektiğimiz senaryo
      final response = await supabase.from('user_progress').select('''
            completed_topics,
            solved_questions,
            streak_days,
            topic_progress:user_topic_progress(
              title,
              progress
            )
          ''').eq('user_id', user.id).single();

      return ProgressData(
        completedTopics: response['completed_topics'] as int? ?? 0,
        solvedQuestions: response['solved_questions'] as int? ?? 0,
        streakDays: response['streak_days'] as int? ?? 0,
        topicProgresses: (response['topic_progress'] as List<dynamic>?)
                ?.map((e) => TopicProgress(
                      title: e['title'] as String,
                      progress: (e['progress'] as num).toDouble(),
                      solvedQuestions: (e['solved_questions'] as num?)?.toInt() ?? 0,
                    ))
                .toList() ??
            [],
        // Şimdilik Supabase bağlantısında rozetler tablosu olmadığı için
        // boş liste dönüyoruz. İleride 'user_badges' tablosu eklenirse buraya dahil edilir.
        earnedBadges: [],
        allBadges: allAvailableBadges,
      );
    }
  } catch (e) {
    // Şimdilik sahte supabase URL'i kullandığımız veya auth olmadığımız için buraya düşecek.
    debugPrint('Supabase veri çekme hatası: $e');
  }

  // Ağ isteği animasyonunu görmek için kısa bir bekleme süresi
  await Future.delayed(const Duration(milliseconds: 800));

  return ProgressData(
    completedTopics: 3,
    solvedQuestions: 142,
    streakDays: 7,
    topicProgresses: [
      TopicProgress(title: 'Hücre', progress: 0.75, solvedQuestions: 60),
      TopicProgress(title: 'Hücre Zarı', progress: 0.60, solvedQuestions: 52),
      TopicProgress(title: 'Mitoz', progress: 0.30, solvedQuestions: 30),
      TopicProgress(title: 'Mayoz', progress: 0.0, solvedQuestions: 0),
      TopicProgress(title: 'Sindirim', progress: 0.0, solvedQuestions: 0),
    ],
    earnedBadges: [
      allAvailableBadges[0], // İlk Adım
      allAvailableBadges[1], // 7 Gün Serisi
      allAvailableBadges[2], // Hücre Uzmanı
    ],
    allBadges: allAvailableBadges,
  );
});
