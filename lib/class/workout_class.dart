class Workout {
  final int? id;
  final String name;
  final int exerciseId;
  final int sets;

  Workout({this.id, required this.name, required this.exerciseId, required this.sets});

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['workout_id'],
        name: json['workout_name'],
        exerciseId: json['exercise_id'],
        sets: json['sets'],
      );

  Map<String, dynamic> toJson() => {
        'workout_id': id,
        'workout_name': name,
        'exercise_id': exerciseId,
        'sets': sets,
      };
}
