import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/history_class.dart';
import '../class/exercise_class.dart'; 

class MidWorkoutExerciseScreen extends StatefulWidget {
  final int workoutId;
  final List<Exercise> exercises; 
  final int currentIndex;

  const MidWorkoutExerciseScreen({
    super.key,
    required this.workoutId,
    required this.exercises,
    required this.currentIndex,
  });

  @override
  State<MidWorkoutExerciseScreen> createState() =>
      _MidWorkoutExerciseScreenState();
}

class _MidWorkoutExerciseScreenState extends State<MidWorkoutExerciseScreen> {
  static const int maxSupportedSets = 10;

  late Exercise currentExercise; 

  int? previousWeight;
  List<int>? previousRepetitions;

  final TextEditingController weightInputController = TextEditingController();
  final TextEditingController setCountController = TextEditingController();
  final List<TextEditingController> repetitionControllers = [];

  bool isSaving = false;
  bool isLoadingHistory = true; 

  @override
  void initState() {
    super.initState();
    currentExercise = widget.exercises[widget.currentIndex];

    setCountController.text = '3';
    _initializeRepetitionFields(3);

    _loadPreviousHistory();
  }


  Future<void> _loadPreviousHistory() async {
    try {

    } catch (e) {
      print("Error loading history: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingHistory = false;
        });
      }
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

  void _proceedToNextExercise() {
    if (widget.currentIndex < widget.exercises.length - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MidWorkoutExerciseScreen(
            workoutId: widget.workoutId,
            exercises: widget.exercises,
            currentIndex: widget.currentIndex + 1, 
          ),
        ),
      );
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout Completed!")),
      );
    }
  }

  Future<void> _saveExerciseHistory() async {
    if (isSaving) return;

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

    final enteredReps = repetitionControllers
        .map((c) => c.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (enteredReps.isEmpty) {
      _showSnackMessage('Please enter repetitions');
      return;
    }

    final formattedSets = <String>[
      for (final reps in enteredReps) '${parsedWeight}x$reps'
    ];

    setState(() => isSaving = true);

    try {
      await WorkoutDatabase.instance.createExerciseHistory(
        ExerciseHistory(
          id: null,
          workoutId: widget.workoutId,
          exerciseId: currentExercise.id!, 
          date: DateTime.now(),
          sets: formattedSets,
          notes: null,
          exerciseName: currentExercise.name, 
          workoutName: null,
          weight: parsedWeight,
          reps: int.tryParse(enteredReps.first),
        ),
      );

      if (!mounted) return;
      _showSnackMessage('Saved to history');
      
      _proceedToNextExercise(); 

    } catch (error) {
      if (!mounted) return;
      _showSnackMessage('Error saving: $error');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastExercise = widget.currentIndex >= widget.exercises.length - 1;
    final buttonText = isLastExercise ? "Finish Workout" : "Next Exercise";
    final nextButtonColor = isLastExercise ? Colors.green : Colors.blue;

    final previousWeightText = previousWeight != null ? '$previousWeight lbs' : 'N/A';
    final previousRepetitionText = (previousRepetitions != null && previousRepetitions!.isNotEmpty)
            ? previousRepetitions!.join(', ')
            : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text("Exercise ${widget.currentIndex + 1}/${widget.exercises.length}"), // Helpful title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), 
        ),
        actions: [
          TextButton(
            onPressed: _proceedToNextExercise, 
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue[100],
              child: Text(
                currentExercise.name ?? "Unnamed", // Use object
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Weight (lbs): ', style: TextStyle(fontSize: 16)),
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
            Row(
              children: [
                const Text('Number of sets: ', style: TextStyle(fontSize: 16)),
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
            const Text('Repetitions:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            const SizedBox(height: 14),
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: nextButtonColor),
                onPressed: isSaving ? null : _saveExerciseHistory,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}