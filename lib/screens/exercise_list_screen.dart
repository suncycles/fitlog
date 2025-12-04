import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/exercise_class.dart';
import '../class/database_helper.dart';
import '../screens/view_workouts_list_screen.dart';
import '../class/workout_class.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key, required this.primaryMuscle});
  /// Primary muscle group for this list.
  final String primaryMuscle;

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<Exercise> exercises = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future<void> loadExercises() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Loading the database
      final db = await DatabaseHelper.instance.database;

      // Call accessor function to get exercises for the primary muscle
      List<Exercise?> fetchedExercises = await WorkoutDatabase.instance.getExercises(
        primaryMuscle: widget.primaryMuscle,
      );

      // Filter out null values
      List<Exercise> validExercises = [];
      if (fetchedExercises.isNotEmpty) {
        for (var exercise in fetchedExercises) {
          if (exercise != null) {
            validExercises.add(exercise);
          }
        }
      }

      setState(() {
        exercises = validExercises;
        isLoading = false;
      });

      print("Success! Loaded ${exercises.length} exercises for ${widget.primaryMuscle}");
    } catch (e, stackTrace) {
      print("ERROR loading exercises: $e");
      print("Stack trace: $stackTrace");

      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = '${widget.primaryMuscle} Exercises';

    return Scaffold(
      appBar: AppBar(
        // Muscle group title
        title: Text(titleText),
        // Back button
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Error loading exercises',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: loadExercises,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No exercises found for ${widget.primaryMuscle}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ExerciseCard(exercise: exercise),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

/*
Card widget showing one exercise in the list.

Includes:
- Exercise name
- Exercise Demonstration
- "Add to workout" button
*/
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise name and 'Add to workout' button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                exercise.name ?? 'Unknown Exercise',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Go to WorkoutsListScreen to select a workout
                final String? selectedWorkout = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutsListScreen(),
                  ),
                );

                // If the user do not select or click on back button, do nothing
                if (selectedWorkout == null || selectedWorkout.isEmpty) {
                  return;
                }

                // Add the exercise to the selected workout
                try {
                  final db = WorkoutDatabase.instance;
                  const int defaultSets = 3;

                  if (exercise.id == null) {
                    debugPrint('Exercise id is null, cannot save to workout.');
                    return;
                  }

                  final workoutRow = Workout(
                    id: null,
                    name: selectedWorkout,
                    exerciseId: exercise.id!,
                    sets: defaultSets,
                  );
                  await db.createWorkout(workoutRow);

                  // Successfully added
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added "${exercise.name}" to "$selectedWorkout"',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add exercise: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Add to workout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Exercise demonstration
        Container(
          width: double.infinity,
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 204, 204),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Exercise Demonstration',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}