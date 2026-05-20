import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/calculation_service.dart';
import '../services/storage_service.dart';
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final calculationServiceProvider = Provider<CalculationService>((ref) {
  return const CalculationService();
});

/// Holds the active user profile and syncs with SharedPreferences.
class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier(this._storage) : super(null);

  final StorageService _storage;

  UserProfile? get profile => state;

  Future<void> loadProfile(String uid) async {
    final profile = await _storage.getProfile(uid);
    state = profile;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _storage.saveProfile(profile);
    state = profile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await saveProfile(profile);
  }

  Future<void> clear() async {
    state = null;
  }

  void recalculate() {
    if (state != null) {
      state = state;
    }
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, UserProfile?>((ref) {
  return UserNotifier(ref.watch(storageServiceProvider));
});

/// Derived fitness results from the current profile.
final fitnessResultsProvider = Provider((ref) {
  final profile = ref.watch(userProvider);
  final calc = ref.watch(calculationServiceProvider);
  if (profile == null) return null;
  return calc.compute(profile);
});
