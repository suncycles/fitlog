import 'package:flutter/material.dart';
import '../screens/view_workouts_list_screen.dart'; 
import '../class/workout_class.dart';
import '../class/accessor_functions.dart';
import '../class/exercise_class.dart'; 

class ExerciseViewScreen extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseViewScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<ExerciseViewScreen> createState() => _ExerciseViewScreenState();
}

class _ExerciseViewScreenState extends State<ExerciseViewScreen> {
  Exercise? _exerciseDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExerciseDetails();
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

  Future<void> _addExerciseToWorkout(BuildContext context) async {
    final selectedWorkout = await Navigator.push<WorkoutGroup>(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkoutsListScreen(selectMode: true), 
      ),
    );

    if (selectedWorkout == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout selection cancelled.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    const int defaultSets = 3;

    final workoutRow = Workout(
      id: null,
      name: selectedWorkout.name,
      exerciseId: widget.exerciseId, 
      sets: defaultSets,
    );
    
    await WorkoutDatabase.instance.createWorkout(workoutRow);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added "${widget.exerciseName}" to workout "${selectedWorkout.name}"',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_exerciseDetails == null) {
      return const Center(child: Text('Exercise details not found.'));
    }

    final String primaryMuscle = _exerciseDetails!.primaryMuscles ?? 'N/A';
    final String secondaryMuscles = _exerciseDetails!.secondaryMuscles ?? 'N/A';
    final String equipment = _exerciseDetails!.equipment ?? 'N/A';
    final String instructions = _exerciseDetails!.instructions ?? 'No detailed instructions available.';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Exercise Demonstration Area
          Container(
            height: 250,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.shade200),
            ),
            child: const Text(
              'Exercise Demonstration Video/GIF',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          
          const SizedBox(height: 24),
          
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

          const Text(
            'Instructions:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            instructions,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 40),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Add to an Existing Workout',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => _addExerciseToWorkout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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