import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../main.dart'; // For sharedPreferencesProvider
import '../../providers/theme_provider.dart';

// --- Notification Logic ---

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notifService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(prefs, notifService);
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> enableStreakReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'streak_reminders',
      'Çalışma Hatırlatıcıları',
      channelDescription: 'Günlük çalışma serisini hatırlatan bildirimler',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.cancelAll();
    
    await _notificationsPlugin.periodicallyShow(
      id: 0,
      title: 'Zaman Geldi! 🧬',
      body: 'Serini bozma, Biyoloji Atlası seni bekliyor!',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> disableAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }
}

class NotificationNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  final NotificationService _notificationService;
  static const _key = 'notifications_enabled';

  NotificationNotifier(this._prefs, this._notificationService)
      : super(_prefs.getBool(_key) ?? false) {
    if (state) {
      _notificationService.enableStreakReminder();
    }
  }

  Future<void> toggleNotifications() async {
    final newState = !state;
    state = newState;
    await _prefs.setBool(_key, newState);

    if (newState) {
      await _notificationService.enableStreakReminder();
    } else {
      await _notificationService.disableAllReminders();
    }
  }
}

// --- Settings Screen ---

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final notificationsEnabled = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          const _SectionHeader(title: AppStrings.account),
          _SettingsTile(
            icon: Icons.person_outline,
            title: AppStrings.profile,
            onTap: () {
              context.push('/profile');
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: AppStrings.notifications,
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (_) => ref.read(notificationProvider.notifier).toggleNotifications(),
            ),
            onTap: () => ref.read(notificationProvider.notifier).toggleNotifications(),
          ),
          const _SectionHeader(title: AppStrings.app),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: AppStrings.darkMode,
            trailing: Switch(
              value: isDarkMode,
              onChanged: (_) {
                ref.read(themeModeProvider.notifier).state =
                    isDarkMode ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            onTap: () {
              ref.read(themeModeProvider.notifier).state =
                  isDarkMode ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const _SectionHeader(title: AppStrings.about),
          _SettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.aboutApp,
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.privacyPolicy,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (_) {}

                if (kIsWeb) {
                  if (context.mounted) {
                    context.go('/login');
                  }
                  return;
                }

                if (Platform.isIOS) {
                  if (context.mounted) {
                    context.go('/login');
                  }
                } else {
                  SystemNavigator.pop();
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
