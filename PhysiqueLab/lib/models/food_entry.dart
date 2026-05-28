/// A single logged food item for a given day.
class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.mealType,
    required this.date,
  });

  final String id;
  final String name;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String mealType;
  final String date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'proteinG': proteinG,
        'fatG': fatG,
        'carbsG': carbsG,
        'mealType': mealType,
        'date': date,
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['proteinG'] as num).toDouble(),
      fatG: (json['fatG'] as num).toDouble(),
      carbsG: (json['carbsG'] as num).toDouble(),
      mealType: json['mealType'] as String,
      date: json['date'] as String,
    );
  }
}

const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
