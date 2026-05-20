import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/results_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/stat_card.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Workout tab — split recommendation and weekly schedule grid.
class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(resultsProvider);
    final schedule = ref.watch(weeklyScheduleProvider);

    if (results == null || schedule == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text('Workout', style: AppTextStyles.heading),
        const SizedBox(height: 20),
        StatCard(
          title: 'Recommended Split',
          value: results.workoutSplit,
          subtitle: results.workoutFrequency,
          icon: Icons.calendar_month,
          animationIndex: 0,
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Weekly Schedule'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            final dayLabel = schedule[index];
            final isRest = dayLabel == 'Rest';
            return Column(
              children: [
                Text(_days[index], style: AppTextStyles.caption),
                const SizedBox(height: 6),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isRest ? const Color(0xFF2A2A2A) : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isRest ? const Color(0xFF333333) : AppColors.primary,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayLabel,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: isRest ? AppColors.textCaption : AppColors.primaryLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Training Days'),
        ...schedule.where((d) => d != 'Rest').toSet().map(
              (type) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type, style: AppTextStyles.subheading.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        _dayDescription(type),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 12),
        StatCard(
          title: 'Steps Target',
          value: '${results.stepsMin.withThousandsSeparator()} – ${results.stepsMax.withThousandsSeparator()}',
          subtitle: 'Keep moving — every step counts toward your goal',
          icon: Icons.directions_run,
          animationIndex: 1,
        ),
      ],
    );
  }

  String _dayDescription(String type) {
    return switch (type) {
      'Push' => 'Chest, shoulders, and triceps focused session.',
      'Pull' => 'Back and biceps focused session.',
      'Legs' => 'Quads, hamstrings, glutes, and calves.',
      'Upper' => 'Upper body compound and isolation work.',
      'Lower' => 'Lower body strength and hypertrophy.',
      'Full Body' => 'Compound lifts hitting all major muscle groups.',
      'Cardio' => 'Low-to-moderate intensity cardio for fat loss.',
      'Hybrid' => 'Balanced mix of strength and conditioning.',
      _ => 'Active recovery or light activity.',
    };
  }
}
