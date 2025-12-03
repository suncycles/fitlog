import 'package:flutter/material.dart';
import '../class/accessor_functions.dart';
import '../class/database_helper.dart';
import '../class/workout_class.dart';
import '../class/exercise_class.dart';
import 'view_workout_single_screen.dart';
import 'exercise_list_screen.dart';
import 'create_workout_screen.dart';


class WorkoutsListScreen extends StatefulWidget {
  const WorkoutsListScreen({super.key});

  @override
  State<WorkoutsListScreen> createState() => _WorkoutsListScreenState();
}

class _WorkoutsListScreenState extends State<WorkoutsListScreen> {
  List<WorkoutGroup> workouts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
    //testWorkout();
  }


  /*
  // Test to add exercises into workout
  Future<void> testWorkout() async {
    final db = await DatabaseHelper.instance.database;

    await WorkoutDatabase.instance.createWorkout(Workout(id: null, name: 'Test Workout 2', exerciseId: 1, sets: 3),
    );
    await WorkoutDatabase.instance.createWorkout(Workout(id: null, name: 'Test Workout 2', exerciseId: 2, sets: 4),
    );
    await WorkoutDatabase.instance.createWorkout(Workout(id: null, name: 'Test Workout 2', exerciseId: 3, sets: 5),
    );
    await loadWorkouts();
  }
  */

  Future<void> loadWorkouts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final db = await DatabaseHelper.instance.database;

      List<WorkoutGroup> workoutGroup = await WorkoutDatabase.instance.getGroupedWorkouts();

      setState(() {
        workouts = workoutGroup;
        isLoading = false;
      });
      print("Loaded ${workouts.length} workouts");
    }

    catch (e, stack) {
      print ("Error loading workouts: $e");
      print(stack);

      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Expanded(
                child: errorMessage != null ? 
                _ErrorView(errorMessage!): 
                    workouts.isEmpty
                        ? const _EmptyView(): 
                        ListView.builder(
                            itemCount: workouts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _WorkoutCard(workout: workouts[index]),
                              );
                            },
                        ),
              ),
              // Green Create New Workout button at the bottom
              _CreateWorkoutCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateWorkoutScreen(),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No workouts found",
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({super.key, required this.workout});

  final WorkoutGroup workout;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  SingleWorkoutScreen(workoutGroup: workout,),
          ),
        );
        debugPrint("Tapped workout: ${workout.name}");
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 204, 229, 255),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout name
            Text(
              workout.name ?? "Unnamed Workout",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Number of exercises
            Text(
              "${workout.exercisesInWorkout.length} exercises",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateWorkoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateWorkoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Text(
            "Create New Workout",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


class _ErrorView extends StatelessWidget {
  const _ErrorView(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize:18),
      ),
    );
  }
}
