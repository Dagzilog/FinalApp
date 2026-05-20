import 'goal_type.dart';

/// User demographic and goal data persisted locally per Firebase UID.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    this.email,
  });

  final String uid;
  final String fullName;
  final int age;
  final double heightCm;
  final double weightKg;
  final GoalType goal;
  final String? email;

  UserProfile copyWith({
    String? uid,
    String? fullName,
    int? age,
    double? heightCm,
    double? weightKg,
    GoalType? goal,
    String? email,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'goal': goal.storageKey,
        'email': email,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String,
      age: json['age'] as int,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      goal: GoalTypeParsing.fromString(json['goal'] as String),
      email: json['email'] as String?,
    );
  }
}
