import 'package:flutter/material.dart';
import 'package:fitlog/class/accessor_functions.dart';
import 'package:fitlog/class/database_helper.dart';
import 'package:fitlog/class/exercise_class.dart';
import 'package:fitlog/class/workout_class.dart';
import 'package:fitlog/class/history_class.dart';

class DbTest extends StatefulWidget {
  const DbTest({super.key});

  @override
  State<DbTest> createState() => _DbTestState();
}

class _DbTestState extends State<DbTest> {
  String result = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    testAllAccessorFunctions();
  }

  Future<void> testAllAccessorFunctions() async {
    StringBuffer output = StringBuffer();
    
    try {
      output.writeln("=== DATABASE ACCESSOR FUNCTION TESTS ===\n");

      // Loading the database
      final db = await DatabaseHelper.instance.database;
      output.writeln("✓ Database loaded successfully\n");

      // TEST 1: getExercise(id)
      output.writeln("--- TEST 1: getExercise(id) ---");
      Exercise? exercise = await WorkoutDatabase.instance.getExercise(1);
      if (exercise != null) {
        output.writeln("✓ Found exercise with ID 1:");
        output.writeln("  Name: ${exercise.name}");
        output.writeln("  Primary Muscles: ${exercise.primaryMuscles}");
        output.writeln("  Equipment: ${exercise.equipment}");
      } else {
        output.writeln("✗ No exercise found with ID 1");
      }
      output.writeln();

      // TEST 2: getExercises() - Get all exercises
      output.writeln("--- TEST 2: getExercises() - Get ALL ---");
      List<Exercise?> allExercises = await WorkoutDatabase.instance.getExercises();
      output.writeln("✓ Total exercises in database: ${allExercises.length}");
      if (allExercises.isNotEmpty && allExercises.first != null) {
        output.writeln("  First exercise: ${allExercises.first!.name}");
      }
      output.writeln();

      // TEST 3: getExercises(primaryMuscle)
      output.writeln("--- TEST 3: getExercises(primaryMuscle: 'chest') ---");
      List<Exercise?> chestExercises = await WorkoutDatabase.instance.getExercises(
        primaryMuscle: 'chest'
      );
      output.writeln("✓ Found ${chestExercises.length} chest exercises");
      int displayCount = chestExercises.length > 3 ? 3 : chestExercises.length;
      for (int i = 0; i < displayCount; i++) {
        if (chestExercises[i] != null) {
          output.writeln("  ${i + 1}. ${chestExercises[i]!.name}");
        }
      }
      if (chestExercises.length > 3) {
        output.writeln("  ... and ${chestExercises.length - 3} more");
      }
      output.writeln();

      // TEST 4: getExercises(search)
      output.writeln("--- TEST 4: getExercises(search: 'push') ---");
      List<Exercise?> searchResults = await WorkoutDatabase.instance.getExercises(
        search: 'push'
      );
      output.writeln("✓ Found ${searchResults.length} exercises matching 'push'");
      displayCount = searchResults.length > 3 ? 3 : searchResults.length;
      for (int i = 0; i < displayCount; i++) {
        if (searchResults[i] != null) {
          output.writeln("  ${i + 1}. ${searchResults[i]!.name}");
        }
      }
      if (searchResults.length > 3) {
        output.writeln("  ... and ${searchResults.length - 3} more");
      }
      output.writeln();

      // TEST 5: getPrimaryMuscles()
      output.writeln("--- TEST 5: getPrimaryMuscles() ---");
      List<String> primaryMuscles = await WorkoutDatabase.instance.getPrimaryMuscles();
      output.writeln("✓ Found ${primaryMuscles.length} unique muscle groups:");
      for (var muscle in primaryMuscles) {
        output.writeln("  • $muscle");
      }
      output.writeln();

      // TEST 6: getWorkouts()
      output.writeln("--- TEST 6: getWorkouts() ---");
      List<Workout> workouts = await WorkoutDatabase.instance.getWorkouts();
      if (workouts.isEmpty) {
        output.writeln("ℹ No workouts found (database may be empty)");
      } else {
        output.writeln("✓ Found ${workouts.length} workouts:");
        for (var workout in workouts) {
          output.writeln("  • ${workout.name} (ID: ${workout.id})");
        }
      }
      output.writeln();

      // TEST 7: createWorkout() and getWorkout()
      output.writeln("--- TEST 7: createWorkout() & getWorkout() ---");
      Workout newWorkout = Workout(
        id: null,
        name: 'Test Workout ${DateTime.now().millisecondsSinceEpoch}',
        exerciseId: 1,
        sets: 3,
      );
      int workoutId = await WorkoutDatabase.instance.createWorkout(newWorkout);
      output.writeln("✓ Created workout with ID: $workoutId");
      
      Workout? retrievedWorkout = await WorkoutDatabase.instance.getWorkout(workoutId);
      if (retrievedWorkout != null) {
        output.writeln("✓ Retrieved workout: ${retrievedWorkout.name}");
      } else {
        output.writeln("✗ Failed to retrieve workout");
      }
      output.writeln();

      // TEST 8: updateWorkout()
      output.writeln("--- TEST 8: updateWorkout() ---");
      if (retrievedWorkout != null) {
        Workout updatedWorkout = Workout(
          id: retrievedWorkout.id,
          name: '${retrievedWorkout.name} (Updated)',
          exerciseId: retrievedWorkout.exerciseId,
          sets: 5, // Changed from 3 to 5
        );
        int updateResult = await WorkoutDatabase.instance.updateWorkout(updatedWorkout);
        output.writeln("✓ Update result: $updateResult rows affected");
        
        Workout? checkUpdate = await WorkoutDatabase.instance.getWorkout(workoutId);
        if (checkUpdate != null) {
          output.writeln("✓ Updated sets: ${checkUpdate.sets}");
        }
      }
      output.writeln();

      // TEST 9: getExerciseHistory()
      output.writeln("--- TEST 9: getExerciseHistory() ---");
      List<ExerciseHistory> history = await WorkoutDatabase.instance.getExerciseHistory(workoutId);
      if (history.isEmpty) {
        output.writeln("ℹ No exercise history found for workout $workoutId");
      } else {
        output.writeln("✓ Found ${history.length} history entries");
      }
      output.writeln();


      // TEST 11: deleteWorkout() - Clean up test data
      output.writeln("--- TEST 11: deleteWorkout() (Cleanup) ---");
      int deleteResult = await WorkoutDatabase.instance.deleteWorkout(workoutId);
      output.writeln("✓ Deleted test workout, result: $deleteResult");
      output.writeln();

      output.writeln("=== ALL TESTS COMPLETED ===");

      setState(() {
        result = output.toString();
        loading = false;
      });

      print("Success! All accessor functions tested.");
      
    } catch (e, stackTrace) {
      print("ERROR: $e");
      print("Stack trace: $stackTrace");
      
      setState(() {
        result = "Error during testing:\n\n$e\n\nStack trace:\n$stackTrace";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Accessor Tests'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: loading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Running database tests...'),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Test Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => loading = true);
                              testAllAccessorFunctions();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Rerun'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        result,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}