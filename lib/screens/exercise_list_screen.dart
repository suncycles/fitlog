import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/exercise_class.dart';
import '../class/database_helper.dart';
import '../class/accessor_functions.dart';
import '../class/exercise_class.dart';


class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key, required this.primaryMuscle});
  /// Primary muscle group for this list.
  final String primaryMuscle;

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {

  late Future<List<Exercise>> _futureExercises;
  List<List<Exercise?>> _exercises = [];
  List<String> _muscleGroups = [];
  String? _selectedMuscleGroup;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    List<String> muscleGroups = await WorkoutDatabase.instance.getPrimaryMuscles();
    
    List<List<Exercise?>> exercises = []; // Clean up later

    if(muscleGroups != null){
      for(var muscle in muscleGroups) {
        List<Exercise?> groupExercises = await WorkoutDatabase.instance.getExercises();
        exercises.add(groupExercises);
      }
    }
    setState(() {
      _muscleGroups = muscleGroups;
      _exercises = exercises;
      _isLoading = false;
    });
  }

  /*
  Load all exercises for the given primary muscle from the database.

  Args:
    none

  Returns:
    type: Future<List<Exercise>>: all exercises for that muscle.
  */


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
          child: FutureBuilder<List<Exercise>>(
            future: _futureExercises,
            builder: (context, snapshot) {
              final exercises = snapshot.data ?? [];

              if (exercises.isEmpty) {
                return const Center(
                  child: Text('No exercises found for this muscle group.'),
                );
              }

              return ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ExerciseCard(exercise: exercise),
                  );
                },
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
                exercise.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: connect to workout builder later
                debugPrint('Add ${exercise.name} to a workout');
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
