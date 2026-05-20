import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/fitness_results.dart';
import 'user_provider.dart';

/// Re-exports derived [FitnessResults] for screens that only need metrics.
final resultsProvider = Provider<FitnessResults?>((ref) {
  return ref.watch(fitnessResultsProvider);
});

/// Weekly workout schedule labels for the current goal.
final weeklyScheduleProvider = Provider<List<String>?>((ref) {
  final profile = ref.watch(userProvider);
  if (profile == null) return null;
  return ref.watch(calculationServiceProvider).weeklySchedule(profile.goal);
});
