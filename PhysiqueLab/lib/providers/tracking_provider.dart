import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/custom_workout.dart';
import '../models/food_entry.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/date_utils.dart';
import 'user_provider.dart';

Map<String, int> _stepsMapFromTracking(Map<String, dynamic> data) {
  final raw = data['stepsLog'];
  if (raw is! Map) return {};
  return raw.map((key, value) => MapEntry(key as String, (value as num).toInt()));
}

List<FoodEntry> _foodFromTracking(Map<String, dynamic> data) {
  final raw = data['foodLog'];
  if (raw is! List) return [];
  return raw
      .map((e) => FoodEntry.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

List<CustomWorkout> _workoutsFromTracking(Map<String, dynamic> data) {
  final raw = data['customWorkouts'];
  if (raw is! List) return [];
  return raw
      .map((e) => CustomWorkout.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

Map<int, String> _scheduleFromTracking(Map<String, dynamic> data) {
  final raw = data['workoutSchedule'];
  if (raw is! Map) return {};
  return raw.map((key, value) => MapEntry(int.parse(key as String), value as String));
}

bool _customOnlyFromTracking(Map<String, dynamic> data) {
  return data['useCustomScheduleOnly'] as bool? ?? false;
}

/// Today's logged step count.
class StepsNotifier extends StateNotifier<int> {
  StepsNotifier(this._storage, this._firestore) : super(0);

  final StorageService _storage;
  final FirestoreService _firestore;
  String? _uid;
  Map<String, int> _stepsLog = {};

  Future<void> load(String uid) async {
    _uid = uid;
    final tracking = await _firestore.getTrackingData(uid);
    _stepsLog = _stepsMapFromTracking(tracking);
    if (_stepsLog.isEmpty) {
      final local = await _storage.getTodaySteps(uid);
      if (local > 0) {
        _stepsLog = {todayDateKey(): local};
      }
    }
    state = _stepsLog[todayDateKey()] ?? 0;
  }

  Future<void> setSteps(int steps) async {
    if (_uid == null) return;
    _stepsLog = {..._stepsLog, todayDateKey(): steps};
    await _storage.saveTodaySteps(_uid!, steps);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsLog,
      foodLog: _foodFromTracking(tracking),
      customWorkouts: _workoutsFromTracking(tracking),
      workoutSchedule: _scheduleFromTracking(tracking),
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = steps;
  }

  void clear() {
    _uid = null;
    _stepsLog = {};
    state = 0;
  }
}

final stepsProvider = StateNotifierProvider<StepsNotifier, int>((ref) {
  return StepsNotifier(
    ref.watch(storageServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

/// All food entries; filtered by today in [todayFoodLogProvider].
class FoodLogNotifier extends StateNotifier<List<FoodEntry>> {
  FoodLogNotifier(this._storage, this._firestore) : super([]);

  final StorageService _storage;
  final FirestoreService _firestore;
  String? _uid;

  Future<void> load(String uid) async {
    _uid = uid;
    final tracking = await _firestore.getTrackingData(uid);
    final cloud = _foodFromTracking(tracking);
    state = cloud.isNotEmpty ? cloud : await _storage.getFoodLog(uid);
  }

  Future<void> addEntry(FoodEntry entry) async {
    if (_uid == null) return;
    final updated = [...state, entry];
    await _storage.saveFoodLog(_uid!, updated);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: updated,
      customWorkouts: _workoutsFromTracking(tracking),
      workoutSchedule: _scheduleFromTracking(tracking),
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = updated;
  }

  Future<void> removeEntry(String id) async {
    if (_uid == null) return;
    final updated = state.where((e) => e.id != id).toList();
    await _storage.saveFoodLog(_uid!, updated);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: updated,
      customWorkouts: _workoutsFromTracking(tracking),
      workoutSchedule: _scheduleFromTracking(tracking),
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = updated;
  }

  void clear() {
    _uid = null;
    state = [];
  }
}

final foodLogProvider = StateNotifierProvider<FoodLogNotifier, List<FoodEntry>>((ref) {
  return FoodLogNotifier(
    ref.watch(storageServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

final todayFoodLogProvider = Provider<List<FoodEntry>>((ref) {
  final today = todayDateKey();
  return ref.watch(foodLogProvider).where((e) => e.date == today).toList();
});

class DailyFoodTotals {
  const DailyFoodTotals({
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });

  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;

  static const empty = DailyFoodTotals(calories: 0, proteinG: 0, fatG: 0, carbsG: 0);
}

final dailyFoodTotalsProvider = Provider<DailyFoodTotals>((ref) {
  final entries = ref.watch(todayFoodLogProvider);
  if (entries.isEmpty) return DailyFoodTotals.empty;
  return DailyFoodTotals(
    calories: entries.fold(0.0, (sum, e) => sum + e.calories),
    proteinG: entries.fold(0.0, (sum, e) => sum + e.proteinG),
    fatG: entries.fold(0.0, (sum, e) => sum + e.fatG),
    carbsG: entries.fold(0.0, (sum, e) => sum + e.carbsG),
  );
});

/// User-created custom workouts.
class CustomWorkoutsNotifier extends StateNotifier<List<CustomWorkout>> {
  CustomWorkoutsNotifier(this._storage, this._firestore) : super([]);

  final StorageService _storage;
  final FirestoreService _firestore;
  String? _uid;

  Future<void> load(String uid) async {
    _uid = uid;
    final tracking = await _firestore.getTrackingData(uid);
    final cloud = _workoutsFromTracking(tracking);
    state = cloud.isNotEmpty ? cloud : await _storage.getCustomWorkouts(uid);
  }

  Future<void> addWorkout(CustomWorkout workout) async {
    if (_uid == null) return;
    final updated = [...state, workout];
    await _storage.saveCustomWorkouts(_uid!, updated);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: _foodFromTracking(tracking),
      customWorkouts: updated,
      workoutSchedule: _scheduleFromTracking(tracking),
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = updated;
  }

  Future<void> removeWorkout(String id) async {
    if (_uid == null) return;
    final updated = state.where((w) => w.id != id).toList();
    await _storage.saveCustomWorkouts(_uid!, updated);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: _foodFromTracking(tracking),
      customWorkouts: updated,
      workoutSchedule: _scheduleFromTracking(tracking),
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = updated;
  }

  void clear() {
    _uid = null;
    state = [];
  }
}

final customWorkoutsProvider =
    StateNotifierProvider<CustomWorkoutsNotifier, List<CustomWorkout>>((ref) {
  return CustomWorkoutsNotifier(
    ref.watch(storageServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

/// Mapping from weekday index (0-6) to custom workout id.
class WorkoutScheduleNotifier extends StateNotifier<Map<int, String>> {
  WorkoutScheduleNotifier(this._storage, this._firestore) : super({});

  final StorageService _storage;
  final FirestoreService _firestore;
  String? _uid;

  Future<void> load(String uid) async {
    _uid = uid;
    final tracking = await _firestore.getTrackingData(uid);
    final cloud = _scheduleFromTracking(tracking);
    state = cloud.isNotEmpty ? cloud : await _storage.getWorkoutSchedule(uid);
  }

  Future<void> assignWorkout({
    required int dayIndex,
    required String workoutId,
  }) async {
    if (_uid == null) return;
    final updated = {...state, dayIndex: workoutId};
    await _storage.saveWorkoutSchedule(_uid!, updated);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: _foodFromTracking(tracking),
      customWorkouts: _workoutsFromTracking(tracking),
      workoutSchedule: updated,
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = updated;
  }

  Future<void> clearDay(int dayIndex) async {
    if (_uid == null) return;
    final updated = {...state}..remove(dayIndex);
    await _storage.saveWorkoutSchedule(_uid!, updated);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: _foodFromTracking(tracking),
      customWorkouts: _workoutsFromTracking(tracking),
      workoutSchedule: updated,
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = updated;
  }

  Future<void> removeWorkoutFromSchedule(String workoutId) async {
    if (_uid == null) return;
    final updated = {...state}..removeWhere((_, value) => value == workoutId);
    await _storage.saveWorkoutSchedule(_uid!, updated);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: _foodFromTracking(tracking),
      customWorkouts: _workoutsFromTracking(tracking),
      workoutSchedule: updated,
      useCustomScheduleOnly: _customOnlyFromTracking(tracking),
    );
    state = updated;
  }

  void clear() {
    _uid = null;
    state = {};
  }
}

final workoutScheduleProvider =
    StateNotifierProvider<WorkoutScheduleNotifier, Map<int, String>>((ref) {
  return WorkoutScheduleNotifier(
    ref.watch(storageServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

class CustomScheduleOnlyNotifier extends StateNotifier<bool> {
  CustomScheduleOnlyNotifier(this._storage, this._firestore) : super(false);

  final StorageService _storage;
  final FirestoreService _firestore;
  String? _uid;

  Future<void> load(String uid) async {
    _uid = uid;
    final tracking = await _firestore.getTrackingData(uid);
    if (tracking.isNotEmpty) {
      state = _customOnlyFromTracking(tracking);
      return;
    }
    state = await _storage.getUseCustomScheduleOnly(uid);
  }

  Future<void> setEnabled(bool enabled) async {
    if (_uid == null) return;
    await _storage.saveUseCustomScheduleOnly(_uid!, enabled);
    final tracking = await _firestore.getTrackingData(_uid!);
    await _firestore.saveTrackingData(
      uid: _uid!,
      stepsLog: _stepsMapFromTracking(tracking),
      foodLog: _foodFromTracking(tracking),
      customWorkouts: _workoutsFromTracking(tracking),
      workoutSchedule: _scheduleFromTracking(tracking),
      useCustomScheduleOnly: enabled,
    );
    state = enabled;
  }

  void clear() {
    _uid = null;
    state = false;
  }
}

final customScheduleOnlyProvider =
    StateNotifierProvider<CustomScheduleOnlyNotifier, bool>((ref) {
  return CustomScheduleOnlyNotifier(
    ref.watch(storageServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

/// Loads steps, food log, and custom workouts for the active user.
Future<void> loadTrackingData(WidgetRef ref, String uid) async {
  await Future.wait([
    ref.read(stepsProvider.notifier).load(uid),
    ref.read(foodLogProvider.notifier).load(uid),
    ref.read(customWorkoutsProvider.notifier).load(uid),
    ref.read(workoutScheduleProvider.notifier).load(uid),
    ref.read(customScheduleOnlyProvider.notifier).load(uid),
  ]);
}

void clearTrackingData(WidgetRef ref) {
  ref.read(stepsProvider.notifier).clear();
  ref.read(foodLogProvider.notifier).clear();
  ref.read(customWorkoutsProvider.notifier).clear();
  ref.read(workoutScheduleProvider.notifier).clear();
  ref.read(customScheduleOnlyProvider.notifier).clear();
}
