import 'package:flutter_test/flutter_test.dart';
import 'package:physique_lab/models/goal_type.dart';
import 'package:physique_lab/models/user_profile.dart';
import 'package:physique_lab/services/calculation_service.dart';

void main() {
  const service = CalculationService();

  test('BMI category for normal range', () {
    final bmi = service.calculateBMI(75, 180);
    expect(service.bmiCategory(bmi), 'Normal');
  });

  test('bulk adds 400 kcal to maintenance', () {
    const profile = UserProfile(
      uid: 'test',
      fullName: 'Test User',
      age: 25,
      heightCm: 180,
      weightKg: 80,
      goal: GoalType.bulk,
    );
    final results = service.compute(profile);
    expect(results.maintenanceCalories, 80 * 33);
    expect(results.targetCalories, results.maintenanceCalories + 400);
  });
}
