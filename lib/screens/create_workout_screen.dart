import 'package:flutter/material.dart';

import '../class/accessor_functions.dart';
import '../class/exercise_class.dart';
import '../class/workout_class.dart';

/// One exercise inside a workout (for this screen only).
class _WorkoutExerciseEntry {
  final Exercise exercise;
  final int sets;

  _WorkoutExerciseEntry({
    required this.exercise,
    required this.sets,
  });
}

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final WorkoutDatabase database = WorkoutDatabase.instance;

  // Workout name
  final TextEditingController workoutNameController = TextEditingController();

  // Controls for picking a single exercise to add
  final TextEditingController setCountController = TextEditingController();

  List<String> primaryMuscleOptions = [];
  String? selectedPrimaryMuscle;

  List<Exercise> availableExercises = [];
  Exercise? selectedExercise;

  // Exercises added to this workout
  final List<_WorkoutExerciseEntry> workoutExercises = [];

  bool isLoadingMuscles = true;
  bool isLoadingExercises = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPrimaryMuscles();
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    setCountController.dispose();
    super.dispose();
  }


  Future<void> _loadPrimaryMuscles() async {
    setState(() => isLoadingMuscles = true);

    try {
      final muscles = await database.getPrimaryMuscles();
      setState(() {
        primaryMuscleOptions = muscles;
        if (muscles.isNotEmpty) {
          selectedPrimaryMuscle = muscles.first;
          _loadExercisesForSelectedMuscle();
        }
      });
    } catch (error) {
      _showSnack('Error loading muscle groups: $error');
    } finally {
      if (mounted) {
        setState(() => isLoadingMuscles = false);
      }
    }
  }

  Future<void> _loadExercisesForSelectedMuscle() async {
    if (selectedPrimaryMuscle == null) return;

    setState(() {
      isLoadingExercises = true;
      availableExercises = [];
      selectedExercise = null;
    });

    try {
      final exercises = await database.getExercises(
        primaryMuscle: selectedPrimaryMuscle,
      );

      // works whether getExercises returns List<Exercise> or List<Exercise?>
      final nonNullExercises = exercises.whereType<Exercise>().toList();

      setState(() {
        availableExercises = nonNullExercises;
        if (nonNullExercises.isNotEmpty) {
          selectedExercise = nonNullExercises.first;
        } else {
          selectedExercise = null;
        }
      });
    } catch (error) {
      _showSnack('Error loading exercises: $error');
    } finally {
      if (mounted) {
        setState(() => isLoadingExercises = false);
      }
    }
  }


  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateCurrentExerciseSelection() {
    if (selectedExercise == null) {
      _showSnack('Please select an exercise.');
      return false;
    }

    if (selectedExercise!.id == null) {
      _showSnack('Selected exercise has no ID (check your data).');
      return false;
    }

    final setText = setCountController.text.trim();
    if (setText.isEmpty) {
      _showSnack('Please enter the number of sets.');
      return false;
    }

    final parsedSets = int.tryParse(setText);
    if (parsedSets == null || parsedSets <= 0) {
      _showSnack('Number of sets must be a positive number.');
      return false;
    }

    return true;
  }


  void _addExerciseToWorkout() {
    if (!_validateCurrentExerciseSelection()) return;

    final sets = int.parse(setCountController.text.trim());
    final exercise = selectedExercise!;

    final entry = _WorkoutExerciseEntry(exercise: exercise, sets: sets);

    setState(() {
      workoutExercises.add(entry);
      setCountController.clear(); // reset sets for next add
    });
  }

  void _removeExerciseFromWorkout(int index) {
    setState(() {
      workoutExercises.removeAt(index);
    });
  }


  Future<void> _saveWorkout() async {
    if (isSaving) return;

    final workoutName = workoutNameController.text.trim();
    if (workoutName.isEmpty) {
      _showSnack('Please enter a workout name.');
      return;
    }

    if (workoutExercises.isEmpty) {
      _showSnack('Please add at least one exercise.');
      return;
    }

    setState(() => isSaving = true);

    try {
      // Create one Workout row per exercise, all sharing the same workout name
      for (final entry in workoutExercises) {
        final exercise = entry.exercise;
        if (exercise.id == null) continue; // safety

        final newWorkoutRow = Workout(
          id: null,
          name: workoutName,
          exerciseId: exercise.id!,
          sets: entry.sets,
        );

        await database.createWorkout(newWorkoutRow);
      }

      if (!mounted) return;

      _showSnack('Workout "$workoutName" created.');
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showSnack('Error saving workout: $error');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('back'),
        ),
        title: const Text('Create New Workout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoadingMuscles
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name of Workout
                  const Text(
                    'Name of Workout:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: workoutNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Textbox to name workout',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Controls for picking one exercise to add
                  const Text(
                    'Pick an exercise to add:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Primary muscle dropdown
                  DropdownButtonFormField<String>(
                    value: selectedPrimaryMuscle,
                    items: primaryMuscleOptions
                        .map(
                          (muscle) => DropdownMenuItem<String>(
                            value: muscle,
                            child: Text(muscle),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPrimaryMuscle = value;
                      });
                      _loadExercisesForSelectedMuscle();
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Primary Muscle Group',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Exercise dropdown
                  if (isLoadingExercises)
                    const Center(child: CircularProgressIndicator())
                  else if (availableExercises.isEmpty)
                    const Text(
                      'No exercises found for this muscle group.',
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    DropdownButtonFormField<Exercise>(
                      value: selectedExercise,
                      items: availableExercises
                          .map(
                            (exercise) => DropdownMenuItem<Exercise>(
                              value: exercise,
                              child: Text(exercise.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedExercise = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Exercise',
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Sets for this exercise
                  TextField(
                    controller: setCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number of sets for this exercise',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Add New Exercise button (adds to list, does not save to DB yet)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: _addExerciseToWorkout,
                      child: const Text('Add New Exercise'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List of exercises area
                  const Text(
                    'List of exercises:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: workoutExercises.isEmpty
                          ? const Center(
                              child: Text(
                                '[List of exercises]',
                                style: TextStyle(color: Colors.black45),
                              ),
                            )
                          : ListView.builder(
                              itemCount: workoutExercises.length,
                              itemBuilder: (context, index) {
                                final entry = workoutExercises[index];
                                return ListTile(
                                  title: Text(entry.exercise.name),
                                  subtitle: Text(
                                      '${entry.sets} sets • Primary: ${entry.exercise.primaryMuscles}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _removeExerciseFromWorkout(index),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Done button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveWorkout,
                      child: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Done'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
