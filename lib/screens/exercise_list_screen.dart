import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/exercise_class.dart';
import '../class/database_helper.dart';
import 'exercise_view_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key, required this.primaryMuscle});
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

      final db = await DatabaseHelper.instance.database; 

      List<Exercise?> fetchedExercises = await WorkoutDatabase.instance.getExercises(
        primaryMuscle: widget.primaryMuscle,
      );

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
        title: Text(titleText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorWidget(context)
                  : exercises.isEmpty
                      ? _buildEmptyStateWidget(widget.primaryMuscle)
                      : ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              // Use the new clickable panel
                              child: _ExercisePanel(exercise: exercise),
                            );
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
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
    );
  }

  Widget _buildEmptyStateWidget(String primaryMuscle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No exercises found for $primaryMuscle',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _ExercisePanel extends StatelessWidget {
  const _ExercisePanel({super.key, required this.exercise});

  final Exercise exercise;

  Future<void> _navigateToExerciseView(BuildContext context) async {
    if (exercise.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot view details for an exercise not in the database.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseViewScreen( 
          exerciseId: exercise.id!,
          exerciseName: exercise.name ?? 'Unknown Exercise',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToExerciseView(context),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name ?? 'Unknown Exercise',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Placeholder for Exercise demonstration image/video
              Container(
                width: double.infinity,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 204, 229, 255), 
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Exercise Demonstration (Tap to View)',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}