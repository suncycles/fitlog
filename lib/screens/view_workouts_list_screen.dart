import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/database_helper.dart';
import '../class/workout_class.dart';
import '../class/exercise_class.dart';
import 'view_workout_single_screen.dart';
import 'create_workout_screen.dart';
import 'mid_workout_exercise_screen.dart';

class WorkoutsListScreen extends StatefulWidget {
  const WorkoutsListScreen({
    super.key,
    this.selectMode = false,
  });

  // If true, selecting a workout will return it to the previous screen
  // instead of navigating to the SingleWorkoutScreen.
  final bool selectMode;

  @override
  State<WorkoutsListScreen> createState() => _WorkoutsListScreenState();
}

class _WorkoutsListScreenState extends State<WorkoutsListScreen> {
  List<WorkoutGroup> workouts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load workouts from db
      List<WorkoutGroup> workoutGroups = 
          await WorkoutDatabase.instance.getGroupedWorkouts();

      setState(() {
        workouts = workoutGroups;
        isLoading = false;
      });
      
      print("Loaded ${workouts.length} workouts");
    } catch (e, stack) {
      print("Error loading workouts: $e");
      print(stack);

      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _deleteWorkout(WorkoutGroup workoutGroup) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text(
          'Delete "${workoutGroup.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete all exercises in this workout group
      for (var workout in workoutGroup.exercisesInWorkout) {
        if (workout.id != null) {
          await WorkoutDatabase.instance.deleteWorkout(workout.id!);
        }
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${workoutGroup.name}"'),
          duration: const Duration(seconds: 2),
        ),
      );

      // reload workouts
      loadWorkouts();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting workout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startWorkout(WorkoutGroup workoutGroup) async {
    if (workoutGroup.exercisesInWorkout.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This workout has no exercises')),
      );
      return;
    }

    // Get the first exercise in the group
    final firstWorkout = workoutGroup.exercisesInWorkout.first;
    
    // fetch exercise details using the exerciseId stored in the workout row
    final exercise = await WorkoutDatabase.instance.getExercise(
      firstWorkout.exerciseId,
    );

    if (exercise == null || !mounted) return;

    // Navigate to MidWorkoutExerciseScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidWorkoutExerciseScreen(
         
          workoutId: firstWorkout.id ?? 0, 
          exerciseId: exercise.id ?? 0,
          exerciseName: exercise.name,
          previousWeight: null,
          previousRepetitions: null,
        ),
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadWorkouts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? _ErrorView(
                            errorMessage!,
                            onRetry: loadWorkouts,
                          )
                        : workouts.isEmpty
                            ? const _EmptyView()
                            : ListView.builder(
                                itemCount: workouts.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _WorkoutCard(
                                      workout: workouts[index],
                                      selectMode: widget.selectMode,
                                      onTap: () {
                                        if (widget.selectMode) {
                                          // Return the selected workout to previous screen
                                          Navigator.pop(context, workouts[index]);
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SingleWorkoutScreen(
                                                workoutGroup: workouts[index],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      onStart: () => _startWorkout(workouts[index]),
                                      onDelete: () => _deleteWorkout(workouts[index]),
                                    ),
                                  );
                                },
                              ),
              ),
              // Create New Workout button
              _CreateWorkoutCard(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateWorkoutScreen(),
                    ),
                  );
                  
                  // Reload
                  if (result == true) {
                    loadWorkouts();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fitness_center, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No workouts yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            "Create your first workout to get started!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
    required this.onStart,
    required this.onDelete,
    this.selectMode = false,
  });

  final WorkoutGroup workout;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onDelete;
  final bool selectMode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 204, 229, 255),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout name and delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete workout',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Number of exercises
            Text(
              "${workout.exercisesInWorkout.length} exercise${workout.exercisesInWorkout.length != 1 ? 's' : ''}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),

            // Start Workout button
            if(!selectMode)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Workout'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreateWorkoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateWorkoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Create New Workout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView(this.message, {required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading workouts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}