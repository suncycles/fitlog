import 'package:flutter/material.dart';
import '../screens/view_workouts_list_screen.dart'; 
import '../class/workout_class.dart';
import '../class/accessor_functions.dart'; // Contains WorkoutDatabase
import '../class/exercise_class.dart'; // Contains Exercise class

import '../class/accessor_functions.dart';
import '../class/history_class.dart';
import '../class/workout_class.dart';
import '../class/exercise_class.dart';

class MidWorkoutExerciseScreen extends StatefulWidget {
  final int workoutId;
  final int exerciseId;
  final String exerciseName;

  final int? previousWeight; // last used weight
  final List<int>? previousRepetitions; // last reps for each set

  const MidWorkoutExerciseScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<ExerciseViewScreen> createState() => _ExerciseViewScreenState();
}

class _MidWorkoutExerciseScreenState extends State<MidWorkoutExerciseScreen> {
  static const int maxSupportedSets = 10;

  final TextEditingController weightInputController = TextEditingController();
  final TextEditingController setCountController = TextEditingController();
  final List<TextEditingController> repetitionControllers = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // default sets: 3
    setCountController.text = '3';
    _initializeRepetitionFields(3);

    if (widget.previousWeight != null) {
      weightInputController.text = widget.previousWeight.toString();
    }
  }

  // --- Data Fetching Logic ---
  Future<void> _fetchExerciseDetails() async {
    try {
      final details = await WorkoutDatabase.instance.getExercise(widget.exerciseId);
      setState(() {
        _exerciseDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load exercise details: $e';
        _isLoading = false;
      });
    }
  }

  void _showSnackMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

  void _handleSetCountChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) return;

    final adjustedCount = parsed.clamp(1, maxSupportedSets);
    _initializeRepetitionFields(adjustedCount);
  }

  /// Save this exercise in history, then move to the next exercise (if any).
  Future<void> _saveExerciseHistory() async {
    if (isSaving) return;

    // ---- Validate weight ----
    final weightText = weightInputController.text.trim();
    if (weightText.isEmpty) {
      _showSnackMessage('Please enter a weight');
      return;
    }

    final parsedWeight = int.tryParse(weightText);
    if (parsedWeight == null) {
      _showSnackMessage('Weight must be a number');
      return;
    }

    // ---- Validate repetitions ----
    final enteredReps = repetitionControllers
        .map((c) => c.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (enteredReps.isEmpty) {
      _showSnackMessage('Please enter repetitions');
      return;
    }

    // Build "weight x reps" strings, e.g. "200x8"
    final formattedSets = <String>[
      for (final reps in enteredReps) '${parsedWeight}x$reps'
    ];

    setState(() => isSaving = true);

    try {
      await WorkoutDatabase.instance.createExerciseHistory(
        ExerciseHistory(
          id: null,
          workoutId: widget.workoutId,
          exerciseId: widget.exerciseId,
          date: DateTime.now(),
          sets: formattedSets,
          notes: null,
          // optional UI fields – keep if they exist in your model
          exerciseName: widget.exerciseName,
          workoutName: null,
          weight: parsedWeight,
          reps: int.tryParse(enteredReps.first),
        ),
      );

      if (!mounted) return;

      // After saving, try to move to the next exercise for this workout
      await _goToNextExercise();
    } catch (error) {
      if (!mounted) return;
      _showSnackMessage('Error saving: $error');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  /// Find the next exercise in this workout and navigate to it.
  /// If there is no next exercise, just pop back.
  Future<void> _goToNextExercise() async {
    final db = WorkoutDatabase.instance;

    
    final currentWorkout = await db.getWorkout(widget.workoutId);
    if (currentWorkout == null) {
      if (mounted) Navigator.pop(context); 
      return;
    }

    
    final groupedWorkouts = await db.getGroupedWorkouts();

    WorkoutGroup? currentGroup;
    for (final group in groupedWorkouts) {
      if (group.name == currentWorkout.name) {
        currentGroup = group;
        break;
      }
    }

    if (currentGroup == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final exercisesInWorkout = currentGroup.exercisesInWorkout;
    if (exercisesInWorkout.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }


    final currentIndex =
        exercisesInWorkout.indexWhere((w) => w.id == currentWorkout.id);

    // If not found or already last exercise -> workout finished
    if (currentIndex == -1 || currentIndex + 1 >= exercisesInWorkout.length) {
      if (mounted) Navigator.pop(context);
      return;
    }

    
    final nextWorkout = exercisesInWorkout[currentIndex + 1];

    // Look up the exercise name from exercise_list
    final nextExercise = await db.getExercise(nextWorkout.exerciseId);
    final nextExerciseName = nextExercise?.name ?? 'Exercise';

    if (!mounted) return;

    // 5. Replace this screen with a new mid-workout screen for the next exercise
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MidWorkoutExerciseScreen(
          workoutId: nextWorkout.id!,
          exerciseId: nextWorkout.exerciseId,
          exerciseName: nextExerciseName,
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
        title: Text(widget.exerciseName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Exercise name header
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue[100],
              child: Text(
                widget.exerciseName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Exercise demonstration placeholder
            Container(
              height: 150,
              alignment: Alignment.center,
              color: Colors.pink[100],
              child: const Text(
                '[Exercise Demonstration]',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Previous weight
            Text(
              'Previous Weight: $previousWeightText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Weight input
            Row(
              children: [
                const Text(
                  'Weight (lbs): ',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: TextField(
                    controller: weightInputController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'enter weight',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Number of sets
            Row(
              children: [
                const Text(
                  'Number of sets: ',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: setCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '# sets',
                    ),
                    onChanged: _handleSetCountChanged,
                  ),
                ),
              ],
            ),

    if (_exerciseDetails == null) {
      return const Center(child: Text('Exercise details not found.'));
    }

            const Text(
              'Repetitions:',
              style: TextStyle(fontSize: 16),
            ),
            child: const Text(
              'High-Resolution Exercise Demonstration Video/GIF',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // --- Dynamic Muscle Group and Equipment Info ---
          _buildDetailRow(
            icon: Icons.fitness_center,
            label: 'Primary Muscle',
            value: primaryMuscle,
          ),
          _buildDetailRow(
            icon: Icons.line_weight,
            label: 'Secondary Muscles',
            value: secondaryMuscles,
          ),
          _buildDetailRow(
            icon: Icons.build,
            label: 'Equipment Needed',
            value: equipment,
          ),
          
          const SizedBox(height: 24),

          // Exercise Details Section
          const Text(
            'Instructions:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            instructions,
            style: const TextStyle(fontSize: 16),
          ),

            // Repetition fields
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < repetitionControllers.length; i++)
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: repetitionControllers[i],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Set ${i + 1}',
                        hintText: 'reps',
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 28),

            // Next Exercise button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveExerciseHistory,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Next Exercise'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}