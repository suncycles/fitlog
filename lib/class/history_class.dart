class ExerciseHistory {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final DateTime date;
  final List<String> sets;
  final String? notes;

  ExerciseHistory({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.date,
    required this.sets,
    this.notes,
  });

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) => ExerciseHistory(
        id: json['history_id'],
        workoutId: json['workout_id'],
        exerciseId: json['exercise_id'],
        date: DateTime.parse(json['exercise_date']),
        sets: List<String>.generate(10, (i) => json['set${i + 1}'] ?? '').where((s) => s.isNotEmpty).toList(),
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() {
    final map = {
      'history_id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'exercise_date': date.toIso8601String(),
      'notes': notes,
    };
    for (int i = 0; i < sets.length && i < 10; i++) {
      map['set${i + 1}'] = sets[i];
    }
    return map;
  }
}