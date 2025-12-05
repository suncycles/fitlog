import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Delete "${workoutGroup.name}"?'),
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

    // Loading dialog so the user knows we are fetching data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      List<Exercise> exercisesToRun = [];

      // Loop through every workout item in this group
      for (var item in workoutGroup.exercisesInWorkout) {
        final exercise = await WorkoutDatabase.instance.getExercise(item.exerciseId);
        if (exercise != null) {
          exercisesToRun.add(exercise);
        }
      }

      if (mounted) Navigator.pop(context); 

      if (exercisesToRun.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Could not load exercises for this workout.")),
        );
        return;
      }

      // Go to MidWorkout with the full list
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MidWorkoutExerciseScreen(
            workoutId: workoutGroup.exercisesInWorkout.first.id ?? 0, 
            exercises: exercisesToRun, 
            currentIndex: 0,           
          ),
        ),
      );

    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error starting workout: $e")),
      );
    }
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
                        ? _ErrorView(errorMessage!, onRetry: loadWorkouts)
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
              
              _CreateWorkoutCard(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateWorkoutScreen(),
                    ),
                  );
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
        children: [
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
          color: const Color.fromARGB(255, 242, 242, 242),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              "${workout.exercisesInWorkout.length} exercise${workout.exercisesInWorkout.length != 1 ? 's' : ''}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
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
          color: const Color.fromARGB(255, 69, 151, 192),
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