import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// SharedPreferences wrapper for session and profile persistence.
class StorageService {
  static const _keyUid = 'uid';
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyProfilePrefix = 'profile_';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<void> saveUid(String uid) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUid, uid);
  }

  Future<String?> getUid() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUid);
  }

  Future<void> clearUid() async {
    final prefs = await _prefs;
    await prefs.remove(_keyUid);
  }

  Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboardingSeen, seen);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  String _profileKey(String uid) => '$_keyProfilePrefix$uid';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await _prefs;
    await prefs.setString(
      _profileKey(profile.uid),
      jsonEncode(profile.toJson()),
    );
  }

  Future<UserProfile?> getProfile(String uid) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_profileKey(uid));
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearProfile(String uid) async {
    final prefs = await _prefs;
    await prefs.remove(_profileKey(uid));
  }

  Future<void> clearAll(String uid) async {
    final prefs = await _prefs;
    await prefs.remove(_keyUid);
    await prefs.remove(_profileKey(uid));
  }
}
