/// Fitness transformation phase selected by the user.
enum GoalType {
  bulk,
  leanBulk,
  cut,
  maintain,
}

extension GoalTypeLabel on GoalType {
  String get label => switch (this) {
        GoalType.bulk => 'Bulk',
        GoalType.leanBulk => 'Lean Bulk',
        GoalType.cut => 'Cut',
        GoalType.maintain => 'Maintain',
      };

  String get storageKey => name;
}

extension GoalTypeParsing on GoalType {
  static GoalType fromString(String value) {
    return GoalType.values.firstWhere(
      (g) => g.name == value || g.storageKey == value,
      orElse: () => GoalType.maintain,
    );
  }
}
