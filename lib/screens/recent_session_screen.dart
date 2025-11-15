import 'package:flutter/material.dart';

// adjust paths if your folders are different
import '../class/accessor_functions.dart';
import '../class/history_class.dart';

class RecentSessionScreen extends StatelessWidget {
  const RecentSessionScreen({super.key});

  /// Load the most recent workout session from the history table.
  Future<List<ExerciseHistory>> _loadRecentSession() async {
    final db = WorkoutDatabase.instance;
    final allHistory = await db.getExerciseHistories();

    if (allHistory.isEmpty) return [];

    // newest first
    allHistory.sort((a, b) => b.date.compareTo(a.date));
    final latestDate = allHistory.first.date;

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    // keep only entries from the most recent day
    return allHistory.where((h) => isSameDay(h.date, latestDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Session'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ExerciseHistory>>(
        future: _loadRecentSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final historyEntries = snapshot.data ?? [];

          if (historyEntries.isEmpty) {
            return const Center(
              child: Text('No workout history yet.'),
            );
          }

          final workoutName =
              historyEntries.first.workoutName ?? 'Most Recent Workout';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Text(
                  workoutName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // each history row
                ...historyEntries.map((exercise) {
                  final name = exercise.exerciseName ?? 'Exercise';
                  final weight = exercise.weight;
                  final setCount = exercise.sets.length;
                  final reps = exercise.reps;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name:  Weight: ${weight ?? '-'} lbs',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          '$setCount sets of ${reps ?? '-'} reps',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
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
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
