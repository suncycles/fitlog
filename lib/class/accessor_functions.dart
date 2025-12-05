import 'dart:async';
import 'exercise_class.dart';
import 'history_class.dart';
import 'workout_class.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutDatabase {
  static final WorkoutDatabase instance = WorkoutDatabase._init();
  static Database? _database;

  WorkoutDatabase._init();

  Future<List<Exercise?>> getExercises({String? primaryMuscle, String? search}) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> result;

    if (primaryMuscle != null) {
      result = await db.query(
        'exercise_list',
        where: 'primary_muscles = ?',
        whereArgs: [primaryMuscle],
      );
    } else if (search != null) {
      final searchPattern = '%$search%';
      result = await db.query(
        'exercise_list',
        where: 'exercise_name LIKE ?',
        whereArgs: [searchPattern],
      );
    } else {
      result = await db.query('exercise_list');
    }

    return result.map((map) => Exercise.fromJson(map)).toList();
  }

  Future<Exercise?> getExercise(int id) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'exercise_list',
      where: 'exercise_id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return Exercise.fromJson(result.first);
  }

  Future<List<String>> getPrimaryMuscles() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'exercise_list',
      distinct: true,
      columns: ['primary_muscles'],
    );

    return result.map((row) => row['primary_muscles'] as String).toList();
  }

  Future<List<ExerciseHistory>> getExerciseHistory(int workoutId) async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.query(
      'exercise_history',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );

    return maps.map((map) => ExerciseHistory.fromJson(map)).toList();
  }

  Future<ExerciseHistory?> getLastExerciseHistory(int exerciseId) async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.query(
      'exercise_history',
      where: 'exercise_id = ?', 
      whereArgs: [exerciseId],
      orderBy: 'date DESC',     
      limit: 1,                 
    );

    if (maps.isNotEmpty) {
      return ExerciseHistory.fromJson(maps.first);
    } else {
      return null; 
    }
  }

  Future<int> getExerciseCountForPrimaryMuscle(String primaryMuscle) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM exercise_list WHERE primary_muscles = ?',
      [primaryMuscle],
    );

    if (rows.isEmpty) return 0;
    final Object? value = rows.first['cnt'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.query('workout_builder');
    return maps.map((map) => Workout.fromJson(map)).toList();
  }

  Future<List<WorkoutGroup>> getGroupedWorkouts() async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query('workout_builder');

    if (rows.isEmpty) {
      print("No rows found in workout_builder");
      return [];
    }

    List<Workout> workouts = rows.map((row) => Workout.fromJson(row)).toList();

    Map<String, List<Workout>> grouped = {};
    for (var w in workouts) {
      if (!grouped.containsKey(w.name)) {
        grouped[w.name] = [];
      }
      grouped[w.name]!.add(w);
    }

    List<WorkoutGroup> workoutGroups = grouped.entries
        .map((entry) => WorkoutGroup(
              name: entry.key,
              exercisesInWorkout: entry.value,
            ))
        .toList();

    print("Grouped ${workoutGroups.length} workouts");
    return workoutGroups;
  }


  Future<Workout?> getWorkout(int id) async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.query(
      'workout_builder',
      where: 'workout_id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Workout.fromJson(maps.first);
  }

  Future<int> createWorkout(Workout workout) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('workout_builder', workout.toJson());
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await DatabaseHelper.instance.database;

    if (workout.id == null) return 0;

    return await db.update(
      'workout_builder',
      workout.toJson(),
      where: 'workout_id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await DatabaseHelper.instance.database;

    return await db.delete(
      'workout_builder',
      where: 'workout_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createExerciseHistory(ExerciseHistory history) async {
    final db = await DatabaseHelper.instance.database;
    if (history.id == null) {
      print("DatabaseHelper: Attempting to insert new exercise history...");
      final id = await db.insert(
        'exercise_history', 
        history.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("DatabaseHelper: Insertion successful. New ID: $id");
      return id;
    }else {
      print("DatabaseHelper: Cannot create history; ID is already set (ID: ${history.id}).");
      return history.id!;
    }
  }

  Future<int?> getLastWeightForExercise(int exerciseId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'exercise_history', 
      columns: ['weight'],
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC', 
      limit: 1, // Only get the single most recent one
    );

    if (result.isNotEmpty) {
      // Assuming you have a fromMap or fromJson factory
      return result.first['weight'] as int; 
    } else {
      return null;
    }
  }

  Future<int?> getLastRepsForExercise(int exerciseId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'exercise_history', 
      columns: ['weight'],
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC', 
      limit: 1, // Only get the single most recent one
    );

    if (result.isNotEmpty) {
      // Assuming you have a fromMap or fromJson factory
      return result.first['weight'] as int; 
    } else {
      return null;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) await db.close();
    _database = null;
  }
}
