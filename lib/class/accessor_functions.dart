import 'dart:async';
import 'exercise_class.dart';
import 'history_class.dart';
import 'workout_class.dart';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutDatabase {
  static final WorkoutDatabase instance = WorkoutDatabase._init();
  static Database? _database;

  WorkoutDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workoutDB.db');
    return _database!;
  }


  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    final exists = await File(path).exists();
    if (!exists) {
      final data = await rootBundle.load('DB/workoutDB.db'); 
      final bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, version: 1);
  }

  Future<Exercise?> getExercise(int id) async {
    final db = await WorkoutDatabase.instance.database;

    // Query the exercise_list table
    final result = await db.query(
      'exercise_list',
      where: 'exercise_id = ?',
      whereArgs: [id],
    );


    if (result.isEmpty) {
      return null;
    }

    final exercise = Exercise.fromJson(result.first);

    return exercise;
  }

  Future<List<Exercise>> getExercises({String? primaryMuscle, String? search}) async {
    // Fetching exercises filtered by primaryMuscle
    return [];
  }

  Future<List<String>> getPrimaryMuscles() async {
    // Fetching primary muscle groups
    return ['Chest', 'Back', 'Legs'];
  }

  Future<List<ExerciseHistory>> getExerciseHistory(int workoutId) async {
    // Fetching history for workoutId - do
    final db = await database;
    final List<ExerciseHistory> history = await db.query('exercise_history', where: 'workout_id = ?', whereArgs: [workoutId]).then((maps) => maps.map((map) => ExerciseHistory.fromJson(map)).toList());
    return history;
  }
 

  Future<List<Workout>> getWorkouts() async {
    // Fetching all workouts
    final db = await database;
    final List<Workout> all_workouts = await db.query('workouts').then((maps) => maps.map((map) => Workout.fromJson(map)).toList());

    if (all_workouts.isNotEmpty) {
      return all_workouts;
    } else {
      return [];
    }

  }

  Future<Workout?> getWorkout(int id) async {
    // Fetching workout with id
    final db = await database;
  
    final List<Workout?> workouts = await db.query('workouts', where: 'workout_id = ?', whereArgs: [id]).then((maps) => maps.map((map) => Workout.fromJson(map)).toList());

    if (workouts.isNotEmpty) {
      return workouts.first;
    } else {
      return null;
    }

  }

  Future<int> updateWorkout(Workout workout) async {
    // Updating workout by ID
    final db = await database;
    final int? id = workout.id;
    final List<Workout?> workouts = await db.query('workouts', where: 'workout_id = ?', whereArgs: [id]).then((maps) => maps.map((map) => Workout.fromJson(map)).toList());

    if (workouts.isNotEmpty) {
      return await db.update('workouts', workout.toJson(), where: 'workout_id = ?', whereArgs: [workout.  id]);
    } else {
      return 0;
    }
  
  }

  Future<int> deleteWorkout(int id) async {
    // Deleting workout by ID
    final db = await database;
  
    final List<Workout?> workouts = await db.query('workouts', where: 'workout_id = ?', whereArgs: [id]).then((maps) => maps.map((map) => Workout.fromJson(map)).toList());

    if (workouts.isNotEmpty) {
      return await db.delete('workouts', where: 'workout_id = ?', whereArgs: [id]);
    } else {
      return 0;
    }
  }

  Future<int> createExerciseHistory(ExerciseHistory history) async {
    // Logging history for exercise 
    final db = await database;

    if (history.id != null) {
      return await db.insert('exercise_history', history.toJson());
    } else {
      return 0;
    }
  }

  
  Future<void> close() async {
    final db = _database;
    if (db != null) await db.close();
    _database = null;
  }
}
