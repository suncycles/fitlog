import 'package:flutter/material.dart';
import '../class/exercise_class.dart';
import '../class/workout_class.dart';
import '../class/accessor_functions.dart';
import 'search_screen.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Exercise> _selectedExercises = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /*
  Navigate to the ExerciseListScreen and waits for the user to select an exercise. The selected exercise is added to the current workout's exercise list.

  Args:
    None

  Returns:
    Future<void>

  Raises:
    Exception: If navigation fails or unexpected null values
  */
  Future<void> _addNewExercise() async{
    final Exercise? selected = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(
        ),
      ),
    );
    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _selectedExercises.add(selected);
      });
    }
  }

  /*
  Validate the workout name and exercise list, then saves the new workout into the database.

  Args:
    None

  Returns:
    Future<void>

  Raises:
    Exception: database insert fails.
  */
  Future<void> _doneAdding() async{
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name.')),
      );
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = WorkoutDatabase.instance;
      const int defaultSets = 3;

      for (final ex in _selectedExercises) {
        final workoutRow = Workout(
          id: null,
          name: name,
          exerciseId: ex.id!,
          sets: defaultSets,
        );
        await db.createWorkout(workoutRow);
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved!')),
      );

      Navigator.of(context).pop(true); // Go back
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Text field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Give workout a name',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),

              // List of exercises
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey.shade200,
                  ),
                  child: _selectedExercises.isEmpty
                      ? const Center(
                          child: Text(
                            'No exercises added yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _selectedExercises.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final ex = _selectedExercises[index];
                            return ListTile(
                              title: Text(ex.name),
                              subtitle: Text(
                                ex.primaryMuscles,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _selectedExercises.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Add New Exercise Button and Done Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addNewExercise,
                      child: const Text('Add New Exercise'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _doneAdding,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
