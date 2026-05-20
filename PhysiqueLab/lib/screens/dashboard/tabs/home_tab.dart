import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/goal_type.dart';
import '../../../providers/results_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/extensions.dart';
import '../../../utils/greeting_utils.dart';
import '../../../widgets/bmi_badge.dart';
import '../../../widgets/stat_card.dart';

/// Home tab — summary cards, BMI warning, calorie and steps targets.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key, required this.onOpenWorkout});

  final VoidCallback onOpenWorkout;

  Color _goalColor(GoalType goal) {
    return switch (goal) {
      GoalType.bulk => AppColors.primary,
      GoalType.leanBulk => AppColors.primaryLight,
      GoalType.cut => AppColors.warning,
      GoalType.maintain => AppColors.success,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProvider);
    final results = ref.watch(resultsProvider);

    if (profile == null || results == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${timeGreeting()}, ${profile.fullName.split(' ').first}!',
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _goalColor(profile.goal).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _goalColor(profile.goal)),
                  ),
                  child: Text(
                    profile.goal.label,
                    style: AppTextStyles.caption.copyWith(color: _goalColor(profile.goal)),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              StatCard(
                title: 'BMI',
                value: '',
                animationIndex: 0,
                child: BmiBadge(bmi: results.bmi, category: results.bmiCategory),
              ),
              if (results.bmiWarning != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(results.bmiWarning!, style: AppTextStyles.body),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              StatCard(
                title: 'Daily Calorie Target',
                value: '${results.targetCalories.round()} kcal',
                subtitle: 'Maintenance: ${results.maintenanceCalories.round()} kcal',
                icon: Icons.local_fire_department,
                accentColor: AppColors.primary,
                animationIndex: 1,
              ),
              const SizedBox(height: 12),
              StatCard(
                title: 'Daily Steps',
                value: '${results.stepsMin.withThousandsSeparator()} – ${results.stepsMax.withThousandsSeparator()}',
                subtitle: 'Stay active to hit your goal',
                icon: Icons.directions_walk,
                animationIndex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Steps', style: AppTextStyles.caption),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        height: 80,
                        width: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: 0.65,
                              strokeWidth: 8,
                              backgroundColor: const Color(0xFF2A2A2A),
                              color: AppColors.primary,
                            ),
                            Text(
                              '65%',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${results.stepsMin.withThousandsSeparator()} – ${results.stepsMax.withThousandsSeparator()} steps',
                      style: AppTextStyles.subheading.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onOpenWorkout,
                child: StatCard(
                  title: 'Workout Plan',
                  value: results.workoutSplit,
                  subtitle: 'Tap to view your weekly schedule',
                  icon: Icons.fitness_center,
                  animationIndex: 3,
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}
