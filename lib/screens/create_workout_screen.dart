import 'package:flutter/material.dart';

import '../class/accessor_functions.dart';
import '../class/exercise_class.dart';
import '../class/workout_class.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final WorkoutDatabase database = WorkoutDatabase.instance;

  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController setCountController = TextEditingController();

  List<String> primaryMuscleOptions = [];
  String? selectedPrimaryMuscle;

  List<Exercise> availableExercises = [];
  Exercise? selectedExercise;

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

  bool _validateInput() {
    final workoutName = workoutNameController.text.trim();
    final setCountText = setCountController.text.trim();

    if (workoutName.isEmpty) {
      _showSnack('Please enter a workout name.');
      return false;
    }

    if (selectedExercise == null) {
      _showSnack('Please select an exercise.');
      return false;
    }

    if (selectedExercise!.id == null) {
      _showSnack('Selected exercise has no ID (check your data).');
      return false;
    }

    if (setCountText.isEmpty) {
      _showSnack('Please enter the number of sets.');
      return false;
    }

    final parsedSets = int.tryParse(setCountText);
    if (parsedSets == null || parsedSets <= 0) {
      _showSnack('Number of sets must be a positive number.');
      return false;
    }

    return true;
  }

 

  Future<void> _saveWorkout() async {
    if (isSaving) return;
    if (!_validateInput()) return;

    final workoutName = workoutNameController.text.trim();
    final setCount = int.parse(setCountController.text.trim());
    final exercise = selectedExercise!;

    setState(() => isSaving = true);

    try {
      final newWorkout = Workout(
        id: null,
        name: workoutName,
        exerciseId: exercise.id!, 
        sets: setCount,
      );

      await database.createWorkout(newWorkout);

      if (!mounted) return;

      _showSnack('Workout created successfully.');

      
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
        title: const Text('Create New Workout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoadingMuscles
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // Workout name
                  const Text(
                    'Workout Name',
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
                      hintText: 'e.g. Push Day, Leg Day',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Primary muscle group
                  const Text(
                    'Primary Muscle Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Exercise list
                  const Text(
                    'Select Exercise',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Number of sets
                  const Text(
                    'Number of Sets',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: setCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'e.g. 3',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveWorkout,
                      child: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Workout'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
