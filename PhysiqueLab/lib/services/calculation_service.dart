import '../models/fitness_results.dart';
import '../models/goal_type.dart';
import '../models/user_profile.dart';

/// Stateless fitness formula engine — all science-backed calculations live here.
class CalculationService {
  const CalculationService();

  double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  String? bmiWarning(double bmi) {
    if (bmi < 18.5) {
      return 'Your BMI suggests you are underweight. A Bulk or Lean Bulk phase may be beneficial.';
    }
    if (bmi >= 25.0 && bmi < 30.0) {
      return 'Your BMI is in the overweight range. A Cut phase may help you reach a healthier weight.';
    }
    if (bmi >= 30.0) {
      return 'Please consult a healthcare professional before beginning an intense training program.';
    }
    return null;
  }

  double maintenanceCalories(double weightKg) => weightKg * 33;

  double targetCalories(double maintenance, GoalType goal) {
    return switch (goal) {
      GoalType.bulk => maintenance + 400,
      GoalType.leanBulk => maintenance + 200,
      GoalType.cut => maintenance - 400,
      GoalType.maintain => maintenance,
    };
  }

  ({double proteinG, double fatG, double carbsG}) calculateMacros(
    double weightKg,
    double totalCalories,
  ) {
    final proteinG = weightKg * 2.2;
    final fatG = weightKg * 0.8;
    final proteinKcal = proteinG * 4;
    final fatKcal = fatG * 9;
    final remainingKcal = totalCalories - proteinKcal - fatKcal;
    final carbsG = remainingKcal > 0 ? remainingKcal / 4.0 : 0.0;
    return (proteinG: proteinG, fatG: fatG, carbsG: carbsG);
  }

  (int min, int max) stepsRange(GoalType goal) {
    return switch (goal) {
      GoalType.bulk => (5000, 7000),
      GoalType.leanBulk => (7000, 9000),
      GoalType.maintain => (8000, 10000),
      GoalType.cut => (10000, 15000),
    };
  }

  (String split, String frequency) workoutRecommendation(GoalType goal) {
    return switch (goal) {
      GoalType.bulk => ('Push / Pull / Legs', '5 to 6 days/week'),
      GoalType.leanBulk => ('Upper / Lower Split', '4 to 5 days/week'),
      GoalType.cut => ('Full Body + Cardio', '4 to 6 days/week'),
      GoalType.maintain => ('Balanced Hybrid Split', '3 to 5 days/week'),
    };
  }

  FitnessResults compute(UserProfile profile) {
    final bmi = calculateBMI(profile.weightKg, profile.heightCm);
    final category = bmiCategory(bmi);
    final maintenance = maintenanceCalories(profile.weightKg);
    final target = targetCalories(maintenance, profile.goal);
    final macros = calculateMacros(profile.weightKg, target);
    final proteinKcal = macros.proteinG * 4;
    final fatKcal = macros.fatG * 9;
    final carbsKcal = macros.carbsG * 4;
    final totalMacroKcal = proteinKcal + fatKcal + carbsKcal;
    final steps = stepsRange(profile.goal);
    final workout = workoutRecommendation(profile.goal);

    double percent(double kcal) =>
        totalMacroKcal > 0 ? (kcal / totalMacroKcal) * 100 : 0;

    return FitnessResults(
      bmi: bmi,
      bmiCategory: category,
      maintenanceCalories: maintenance,
      targetCalories: target,
      proteinG: macros.proteinG,
      fatG: macros.fatG,
      carbsG: macros.carbsG,
      proteinPercent: percent(proteinKcal),
      fatPercent: percent(fatKcal),
      carbsPercent: percent(carbsKcal),
      stepsMin: steps.$1,
      stepsMax: steps.$2,
      workoutSplit: workout.$1,
      workoutFrequency: workout.$2,
      bmiWarning: bmiWarning(bmi),
    );
  }

  /// Weekly training schedule labels for the Workout tab grid.
  List<String> weeklySchedule(GoalType goal) {
    return switch (goal) {
      GoalType.bulk => [
          'Push',
          'Pull',
          'Legs',
          'Push',
          'Pull',
          'Legs',
          'Rest',
        ],
      GoalType.leanBulk => [
          'Upper',
          'Lower',
          'Rest',
          'Upper',
          'Lower',
          'Rest',
          'Rest',
        ],
      GoalType.cut => [
          'Full Body',
          'Cardio',
          'Full Body',
          'Cardio',
          'Full Body',
          'Cardio',
          'Rest',
        ],
      GoalType.maintain => [
          'Hybrid',
          'Rest',
          'Hybrid',
          'Rest',
          'Hybrid',
          'Rest',
          'Rest',
        ],
    };
  }
}
