import 'dart:async';
import 'exercise_class.dart';
import 'history_class.dart';
import 'workout_class.dart';

// All dummy functions. Replace with SQL queris
class WorkoutDatabase {
  static final WorkoutDatabase instance = WorkoutDatabase._init();
  WorkoutDatabase._init();

    //Search specific exercise by Name
  Future<Map<String, dynamic>?> searchExerciseInfo(String exerciseName) async {
    print("Accessing ex Info");
    final results = await db.rawQuery('SELECT * FROM exercise_list WHERE exercise_name = ?', [exerciseName]);
    
    return results;
  }
  
  // Search for a workout by name
  Future<Map<String, dynamic>?> searchWorkout(String workoutName) async {
    print("Accessing workout");
    final results = await db.rawQuery('SELECT * FROM workout_builder WHERE workout_name = ?', [workoutName]);
    
    return results;
  }
  
  // Get history for a specific exercise
  Future<List<Map<String, dynamic>>> getExerciseHistory(int exerciseId) async {
    print("Accessing exercise history");
    final results = await db.rawQuery(('SELECT * FROM exercise_history WHERE exercise_id = ?', [exerciseId]) 5 ORDER BY exercise_date DESC);
  
    return results;
  }
  
  // Create a new workout with exercises
  Future<int> createWorkout(Workout new_workout){
    print("Creating new workout");
  	await db.rawQuery('INSERT INTO workout_builder (new_workout)');
  	print('Successfully Saved workout');
  	return 1;
  }
  
  // Get the most recent workout session by workout name
  Future<Map<String, dynamic>?> getMostRecentWorkout(String workoutName) async {
    print("Getting most recent workout");
    final results = await db.rawQuery('SELECT * FROM exercise_history WHERE workout_id = (SELECT workout_id FROM workout_builder WHERE workout_name = ?', [workoutName]) ORDER BY exercise_date DESC LIMIT 1);
    
    return results;
  }
  
  //Get all exercises for a specific muscle group
  Future<List<Map<String, dynamic>>> getExercisesByMuscleGroup(String muscleGroup) async {  
  	print("Accessing exercies by muscle");
    final results = await db.rawQuery('SELECT * FROM exercise_list WHERE primary_muscles = ?', [muscleGroup]);
    
    return results;
    
  }
  
}
