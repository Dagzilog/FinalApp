import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/custom_workout.dart';
import '../models/food_entry.dart';
import '../models/user_profile.dart';
import '../utils/date_utils.dart';
import 'storage_service.dart';

/// Cloud Firestore wrapper for per-user data sync.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _trackingDoc(String uid) =>
      _userDoc(uid).collection('tracking').doc('data');

  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data();
    if (data == null || data['profile'] == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(data['profile'] as Map));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _userDoc(profile.uid).set({
      'profile': profile.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getTrackingData(String uid) async {
    final snap = await _trackingDoc(uid).get();
    return snap.data() ?? {};
  }

  Future<void> saveTrackingData({
    required String uid,
    required Map<String, int> stepsLog,
    required List<FoodEntry> foodLog,
    required List<CustomWorkout> customWorkouts,
    required Map<int, String> workoutSchedule,
    required bool useCustomScheduleOnly,
  }) async {
    final serializedSchedule =
        workoutSchedule.map((k, v) => MapEntry('$k', v));
    await _trackingDoc(uid).set({
      'stepsLog': stepsLog,
      'foodLog': foodLog.map((e) => e.toJson()).toList(),
      'customWorkouts': customWorkouts.map((w) => w.toJson()).toList(),
      'workoutSchedule': serializedSchedule,
      'useCustomScheduleOnly': useCustomScheduleOnly,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureMigratedFromLocal(
    String uid,
    StorageService storage,
  ) async {
    final userSnap = await _userDoc(uid).get();
    if ((userSnap.data()?['migratedFromLocal'] as bool?) == true) return;

    final localProfile = await storage.getProfile(uid);
    final localSteps = await storage.getTodaySteps(uid);
    final localFood = await storage.getFoodLog(uid);
    final localWorkouts = await storage.getCustomWorkouts(uid);
    final localSchedule = await storage.getWorkoutSchedule(uid);
    final localCustomOnly = await storage.getUseCustomScheduleOnly(uid);

    final batch = _firestore.batch();
    final userRef = _userDoc(uid);
    final trackingRef = _trackingDoc(uid);

    if (localProfile != null && userSnap.data()?['profile'] == null) {
      batch.set(
        userRef,
        {
          'profile': localProfile.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    final trackingSnap = await trackingRef.get();
    if (!trackingSnap.exists) {
      final stepsLog = <String, int>{};
      if (localSteps > 0) {
        stepsLog[todayDateKey()] = localSteps;
      }
      final serializedSchedule = localSchedule.map((k, v) => MapEntry('$k', v));
      batch.set(
        trackingRef,
        {
          'stepsLog': stepsLog,
          'foodLog': localFood.map((e) => e.toJson()).toList(),
          'customWorkouts': localWorkouts.map((w) => w.toJson()).toList(),
          'workoutSchedule': serializedSchedule,
          'useCustomScheduleOnly': localCustomOnly,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    batch.set(
      userRef,
      {
        'migratedFromLocal': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
