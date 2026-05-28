/// A user-created workout with a list of exercises.
class CustomWorkout {
  const CustomWorkout({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<WorkoutExercise> exercises;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'createdAt': createdAt,
      };

  factory CustomWorkout.fromJson(Map<String, dynamic> json) {
    return CustomWorkout(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
    );
  }
}

class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
  });

  final String name;
  final String sets;
  final String reps;

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'] as String,
      sets: json['sets'] as String,
      reps: json['reps'] as String,
    );
  }
}
