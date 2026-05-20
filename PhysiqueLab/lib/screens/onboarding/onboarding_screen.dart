import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Three swipeable intro slides shown once on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.track_changes,
      title: 'Science-Backed Targets',
      description:
          'Get personalized calories, macros, and steps based on your body and goal.',
    ),
    _OnboardingSlide(
      icon: Icons.restaurant_menu,
      title: 'Nutrition Made Clear',
      description:
          'See exactly how much protein, fat, and carbs you need every day.',
    ),
    _OnboardingSlide(
      icon: Icons.fitness_center,
      title: 'Train With Purpose',
      description:
          'Follow a workout split tailored to Bulk, Lean Bulk, Cut, or Maintain.',
    ),
  ];

  Future<void> _finish() async {
    await ref.read(storageServiceProvider).setOnboardingSeen(true);
    if (mounted) context.go('/register');
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Skip', style: AppTextStyles.body.copyWith(color: AppColors.primaryLight)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          ),
                          child: Icon(slide.icon, size: 100, color: AppColors.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(slide.title, style: AppTextStyles.heading, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(slide.description, style: AppTextStyles.body, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : AppColors.textCaption,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: PrimaryButton(
                label: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
