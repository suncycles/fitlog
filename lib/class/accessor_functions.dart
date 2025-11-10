import 'dart:async';
import 'exercise_class.dart';
import 'history_class.dart';
import 'workout_class.dart';

// All dummy functions. Replace with SQL queris
class WorkoutDatabase {
  static final WorkoutDatabase instance = WorkoutDatabase._init();
  WorkoutDatabase._init();

  Future<List<Exercise>> getExercises({String? primaryMuscle, String? search}) async {
    // Fetching exercises filtered by primaryMuscle
    return [];
  }

  Future<Exercise?> getExercise(int id) async {
    // Fetching exercise with id
    return null;
  }

  Future<int> createExercise(Exercise exercise) async {
    // Inserting new exercise into db
    return 1;
  }

  Future<List<String>> getPrimaryMuscles() async {
    // Fetching primary muscle groups
    return ['Chest', 'Back', 'Legs'];
  }

  Future<int> createWorkout(Workout workout) async {
    // Creating workout
    return 1;
  }

  Future<List<Workout>> getWorkouts() async {
    // Fetching all workouts
    return [];
  }

  Future<Workout?> getWorkout(int id) async {
    // Fetching workout with id
    return null;
  }

  Future<int> updateWorkout(Workout workout) async {
    // Updating workout by ID
    return 1;
  }

  Future<int> deleteWorkout(int id) async {
    // Deleting workout by ID
    return 1;
  }

  Future<int> createExerciseHistory(ExerciseHistory history) async {
    // Logging history for exercise
    return 1;
  }

  Future<List<ExerciseHistory>> getExerciseHistory(int workoutId) async {
    // Fetching history for workoutId
    return [];
  }

  Future<int> updateExerciseHistory(ExerciseHistory history) async {
    // Updating exercise history by ID
    return 1;
  }

  Future<int> deleteExerciseHistory(int id) async {
    // Deleting exercise history by ID
    return 1;
  }

  Future close() async {
    // Closing dummy database connection
  }
}
