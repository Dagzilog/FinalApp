/// Computed fitness metrics derived from a [UserProfile].
class FitnessResults {
  const FitnessResults({
    required this.bmi,
    required this.bmiCategory,
    required this.maintenanceCalories,
    required this.targetCalories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.proteinPercent,
    required this.fatPercent,
    required this.carbsPercent,
    required this.stepsMin,
    required this.stepsMax,
    required this.workoutSplit,
    required this.workoutFrequency,
    required this.bmiWarning,
  });

  final double bmi;
  final String bmiCategory;
  final double maintenanceCalories;
  final double targetCalories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double proteinPercent;
  final double fatPercent;
  final double carbsPercent;
  final int stepsMin;
  final int stepsMax;
  final String workoutSplit;
  final String workoutFrequency;
  final String? bmiWarning;
}
