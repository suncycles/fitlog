import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/history_class.dart';

class MidWorkoutExerciseScreen extends StatefulWidget {
  final int workoutId;
  final int exerciseId;
  final String exerciseName;

  final int? previousWeight;               // last used weight
  final List<int>? previousRepetitions;    // last reps for each set

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

    setCountController.text = '3';     // default sets: 3
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

  Future<void> _saveExerciseHistory() async {
    if (isSaving) return;

    //Validate Weight 

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

    // Validate Repetitions
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
          exerciseId: widget.exerciseId,
          date: DateTime.now(),
          sets: formattedSets,
          notes: null,

          // UI only fields
          exerciseName: widget.exerciseName,
          workoutName: null,
          weight: parsedWeight,
          reps: int.tryParse(enteredReps.first),
        ),
      );

      if (!mounted) return;

      _showSnackMessage('Saved to history');
      Navigator.pop(context, true);

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

            Text(
              'Previous Weight: $previousWeightText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
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
