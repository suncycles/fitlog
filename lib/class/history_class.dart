class ExerciseHistory {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final DateTime date;
  final List<String> sets;
  final String? notes;
  final String? exerciseName;   
  final String? workoutName;    
  final int? weight;           
  final int? reps;     
  ExerciseHistory({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.date,
    required this.sets,
    this.notes,
    this.exerciseName,
    this.workoutName,
    this.weight,
    this.reps,
  });

  factory ExerciseHistory.fromJson(Map<String, dynamic> json) => ExerciseHistory(
        id: json['history_id'],
        workoutId: json['workout_id'],
        exerciseId: json['exercise_id'],
        date: DateTime.parse(json['exercise_date']),
        sets: List<String>.generate(10, (i) => json['set${i + 1}'] ?? '').where((s) => s.isNotEmpty).toList(),
        notes: json['notes'],
      );
}