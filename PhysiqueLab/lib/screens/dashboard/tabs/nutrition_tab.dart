import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/results_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/macro_bar.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/stat_card.dart';

/// Nutrition tab — calories, macros, and meal timing guidance.
class NutritionTab extends ConsumerWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(resultsProvider);

    if (results == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text('Nutrition', style: AppTextStyles.heading),
        const SizedBox(height: 20),
        StatCard(
          title: 'Target Calories',
          value: '${results.targetCalories.round()} kcal',
          subtitle: 'Maintenance baseline: ${results.maintenanceCalories.round()} kcal',
          icon: Icons.restaurant,
          accentColor: AppColors.primary,
          animationIndex: 0,
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Macro Breakdown'),
        _MacroRow(
          label: 'Protein',
          grams: results.proteinG,
          percent: results.proteinPercent,
          color: AppColors.macroProtein,
        ),
        _MacroRow(
          label: 'Fat',
          grams: results.fatG,
          percent: results.fatPercent,
          color: AppColors.macroFat,
        ),
        _MacroRow(
          label: 'Carbs',
          grams: results.carbsG,
          percent: results.carbsPercent,
          color: AppColors.macroCarbs,
        ),
        const SizedBox(height: 16),
        MacroBar(
          proteinPercent: results.proteinPercent,
          fatPercent: results.fatPercent,
          carbsPercent: results.carbsPercent,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LegendDot(color: AppColors.macroProtein, label: 'Protein'),
            _LegendDot(color: AppColors.macroFat, label: 'Fat'),
            _LegendDot(color: AppColors.macroCarbs, label: 'Carbs'),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meal Timing', style: AppTextStyles.subheading),
              const SizedBox(height: 8),
              Text(
                'Aim for 3–5 meals per day. Include protein at every meal to support recovery and satiety.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.grams,
    required this.percent,
    required this.color,
  });

  final String label;
  final double grams;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.subheading.copyWith(fontSize: 16))),
          Text('${grams.toDisplayString()} g', style: AppTextStyles.body),
          const SizedBox(width: 16),
          Text('${percent.toDisplayString()}%', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
