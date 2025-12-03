import 'dart:async';
import 'exercise_class.dart';
import 'history_class.dart';
import 'workout_class.dart';
import 'database_helper.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
