import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // TODO: Check auth state and onboarding status
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: const Icon(
                Icons.biotech,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'YKS Biyoloji Atlası',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Ezberleme, Dokun ve Keşfet!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const CircularProgressIndicator(
              color: AppColors.textOnDark,
            ),
          ],
        ),
      ),
    );
  }
}
