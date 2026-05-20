import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../utils/constants.dart';

/// Branded splash with logo animation; routes based on session state.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveRoute();
  }

  Future<void> _resolveRoute() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final storage = ref.read(storageServiceProvider);
    final auth = ref.read(authServiceProvider);
    final uid = await storage.getUid();

    if (uid != null && auth.hasValidSession) {
      final profile = await storage.getProfile(uid);
      if (profile != null) {
        await ref.read(userProvider.notifier).loadProfile(uid);
        if (mounted) context.go('/dashboard');
        return;
      }
      if (mounted) context.go('/setup');
      return;
    }

    if (uid != null && !auth.hasValidSession) {
      await storage.clearUid();
    }

    final seenOnboarding = await storage.hasSeenOnboarding();
    if (!mounted) return;
    if (seenOnboarding) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: AppColors.primary,
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 24),
            Text(
              'PHYSIQUELAB',
              style: AppTextStyles.display.copyWith(
                letterSpacing: 4,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Transform your physique',
              style: AppTextStyles.body,
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
