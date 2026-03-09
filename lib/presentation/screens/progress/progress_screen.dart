import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import 'progress_provider.dart'; // Yeni oluşturduğumuz Provider

// ConsumerWidget kullanarak Riverpod state'ini dinleyebilir hale getiriyoruz.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Burada progressProvider içindeki verimizi AsyncValue olarak okuyoruz.
    // İleride Supabase tam bağlandığında buradaki kod yine aynı kalacak!
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('İlerleme')),
      body: progressAsync.when(
        data: (progressData) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatCard(
                title: 'Tamamlanan Konular',
                value: progressData.completedTopics.toString(),
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                onTap: () => _showCompletedTopicsDialog(context, progressData),
              ),
              const SizedBox(height: AppSpacing.md),
              _StatCard(
                title: 'Çözülen Sorular',
                value: progressData.solvedQuestions.toString(),
                icon: Icons.quiz_outlined,
                color: AppColors.primary,
                onTap: () => _showSolvedQuestionsDialog(context, progressData),
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  final nextMidnight = DateTime(now.year, now.month, now.day + 1);
                  final timeUntilMidnight = nextMidnight.difference(now);
                  
                  Widget? subtitleWidget;
                  if (timeUntilMidnight.inHours < 1) {
                    final minutes = timeUntilMidnight.inMinutes;
                    subtitleWidget = Text(
                      'Sıfırlanmaya ${minutes} dk kaldı!',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  return _StatCard(
                    title: 'Çalışma Serisi',
                    value: '${progressData.streakDays} Gün',
                    icon: Icons.local_fire_department_outlined,
                    color: AppColors.warning,
                    subtitleWidget: subtitleWidget,
                  );
                }
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Kazanılan Rozetler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              progressData.earnedBadges.isEmpty
                  ? const Text(
                      'Henüz rozet kazanmadınız, hemen öğrenmeye başla!',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: progressData.earnedBadges.length,
                        itemBuilder: (context, index) {
                          final badge = progressData.earnedBadges[index];
                          return _BadgeItem(badge: badge);
                        },
                      ),
                    ),
              const SizedBox(height: AppSpacing.lg),
              _AllBadgesSection(
                allBadges: progressData.allBadges,
                earnedBadges: progressData.earnedBadges,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Konu Bazlı İlerleme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...progressData.topicProgresses.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ProgressItem(item: item),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Bir hata oluştu:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }
  void _showCompletedTopicsDialog(BuildContext context, ProgressData data) {
    // Sadece tamamlanma oranı %100 (1.0) olan konuları filtreliyoruz
    final completedTopics =
        data.topicProgresses.where((topic) => topic.progress >= 1.0).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: AppSpacing.sm),
            const Text('Tamamlanan Konular'),
          ],
        ),
        content: completedTopics.isEmpty
            ? const Text('Henüz tamamlanmış bir konu bulunmamaktadır.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: completedTopics.length,
                  itemBuilder: (context, index) {
                    final topic = completedTopics[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          const Icon(Icons.star, color: AppColors.warning),
                      title: Text(
                        topic.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showSolvedQuestionsDialog(BuildContext context, ProgressData data) {
    // Sadece çözülen sorusu 0'dan büyük olanları listeleriz
    final solvedTopics = data.topicProgresses
        .where((topic) => topic.solvedQuestions > 0)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.quiz, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            const Text('Çözülen Sorular'),
          ],
        ),
        content: solvedTopics.isEmpty
            ? const Text('Henüz soru çözülmüş bir konu bulunmamaktadır.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: solvedTopics.length,
                  itemBuilder: (context, index) {
                    final topic = solvedTopics[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        topic.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${topic.solvedQuestions} Soru',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
} // ProgressScreen End

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Widget? subtitleWidget;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (subtitleWidget != null) ...[
              const SizedBox(width: AppSpacing.sm),
              subtitleWidget!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final TopicProgress item; // Artık Map yerine TopicProgress modelimizi kullanıyor

  const _ProgressItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final progress = item.progress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title, // Title'ı modelden çekiyoruz
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '%${(progress * 100).round()}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: progress, // Progress'i modelden çekiyoruz
          backgroundColor: AppColors.surfaceVariant,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final UserBadge badge;

  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.iconPath,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeGridItem extends StatelessWidget {
  final UserBadge badge;
  final bool isEarned;

  const _BadgeGridItem({
    required this.badge,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isEarned ? AppColors.surface : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isEarned 
              ? AppColors.primary.withValues(alpha: 0.5) 
              : Colors.grey.withValues(alpha: 0.3),
          width: isEarned ? 1.5 : 1.0,
        ),
      ),
      child: ColorFiltered(
        colorFilter: isEarned
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
            // Siyah beyaz yapmak için luma algoritmasını taklit eden matris kullanıyoruz
            : const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
        child: Opacity(
          opacity: isEarned ? 1.0 : 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    badge.iconPath,
                    style: const TextStyle(fontSize: 32),
                  ),
                  if (!isEarned)
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEarned ? AppColors.textPrimary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllBadgesSection extends StatefulWidget {
  final List<UserBadge> allBadges;
  final List<UserBadge> earnedBadges;

  const _AllBadgesSection({
    required this.allBadges,
    required this.earnedBadges,
  });

  @override
  State<_AllBadgesSection> createState() => _AllBadgesSectionState();
}

class _AllBadgesSectionState extends State<_AllBadgesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tüm Rozetler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: widget.allBadges.map((badge) {
              final isEarned = widget.earnedBadges
                  .any((earned) => earned.id == badge.id);
              return _BadgeGridItem(badge: badge, isEarned: isEarned);
            }).toList(),
          ),
        ],
      ],
    );
  }
}

