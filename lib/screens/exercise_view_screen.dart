import 'package:flutter/material.dart';

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
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    this.previousWeight,
    this.previousRepetitions,
  });

  @override
  State<MidWorkoutExerciseScreen> createState() =>
      _MidWorkoutExerciseScreenState();
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

  @override
  void dispose() {
    weightInputController.dispose();
    setCountController.dispose();
    for (final controller in repetitionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showSnackMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _initializeRepetitionFields(int count) {
    for (final controller in repetitionControllers) {
      controller.dispose();
    }

    repetitionControllers
      ..clear()
      ..addAll(List.generate(count, (_) => TextEditingController()));

    setState(() {});
  }

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
    final previousWeightText =
        widget.previousWeight != null ? '${widget.previousWeight} lbs' : 'N/A';

    final previousRepetitionText =
        (widget.previousRepetitions != null &&
                widget.previousRepetitions!.isNotEmpty)
            ? widget.previousRepetitions!.join(', ')
            : 'N/A';

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Skip For Now',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
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

            const SizedBox(height: 20),

            const Text(
              'Repetitions:',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 4),

            Text(
              'Previous Repetitions for current weight: $previousRepetitionText',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 14),

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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
      ),
    );
  }
}
