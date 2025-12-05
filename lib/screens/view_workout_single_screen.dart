import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/workout_class.dart';
import '../class/exercise_class.dart';
import 'mid_workout_exercise_screen.dart';

class SingleWorkoutScreen extends StatefulWidget {
  final WorkoutGroup workoutGroup;

  const SingleWorkoutScreen({super.key, required this.workoutGroup});

  @override
  State<SingleWorkoutScreen> createState() => _SingleWorkoutScreenState();
}

class _SingleWorkoutScreenState extends State<SingleWorkoutScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Exercise> exercises = [];

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

      List<Exercise> fetchedExercises = [];

      // Fetch each exercise for this workout
      for (var w in widget.workoutGroup.exercisesInWorkout) {
        final exercise = await WorkoutDatabase.instance.getExercise(w.exerciseId);
        if (exercise != null) {
          fetchedExercises.add(exercise);
        }
      }

      setState(() {
        exercises = fetchedExercises;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> startWorkout() async {
  if (exercises.isEmpty) {
    return;
  }

  // Go to MidWorkoutScreen starting at exercise index 0
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MidWorkoutExerciseScreen(
        workoutId: widget.workoutGroup.id ?? 0,
        exercises: exercises,
        currentIndex: 0, 
      ),
    ),
  );
  
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutGroup.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator()): 
              errorMessage != null
                  ? _ErrorView(errorMessage!, onRetry: loadExercises): 
                  exercises.isEmpty
                      ? const _EmptyView(): 
                      ListView.builder(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: startWorkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 69, 151, 192),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow), 
              SizedBox(width: 8),
              Text(
                "Start Workout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 229, 204),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 100,
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
      ),
    );
  }
}



class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fitness_center, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No exercises found",
            style: TextStyle(fontSize: 18),
          ),
        ],
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
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading exercises',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
