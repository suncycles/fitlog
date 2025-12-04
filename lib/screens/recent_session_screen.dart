import 'package:flutter/material.dart';

import '../class/accessor_functions.dart';
import '../class/history_class.dart';
import '../class/workout_class.dart';

/// Simple view model for displaying recent history rows.
class _RecentHistoryDisplay {
  final String workoutName;
  final int exerciseId;
  final DateTime date;
  final List<String> sets;
  final String? notes;

  _RecentHistoryDisplay({
    required this.workoutName,
    required this.exerciseId,
    required this.date,
    required this.sets,
    this.notes,
  });
}

class RecentSessionScreen extends StatelessWidget {
  const RecentSessionScreen({super.key});

  /// Load the most recent workout session across *all* workouts.
  Future<List<_RecentHistoryDisplay>> _loadRecentSession() async {
    final db = WorkoutDatabase.instance;

    
    final List<Workout> workouts = await db.getWorkouts();
    if (workouts.isEmpty) return [];

    
    final Map<int, String> workoutNamesById = {};
    for (final w in workouts) {
      if (w.id != null) {
        workoutNamesById[w.id!] = w.name;
      }
    }

   
    final List<ExerciseHistory> allHistory = [];
    for (final workout in workouts) {
      final workoutId = workout.id;
      if (workoutId == null) continue;

      final historyForWorkout = await db.getExerciseHistory(workoutId);
      allHistory.addAll(historyForWorkout);
    }

    if (allHistory.isEmpty) return [];

   
    allHistory.sort((a, b) => b.date.compareTo(a.date));
    final DateTime latestDate = allHistory.first.date;

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    
    final List<ExerciseHistory> latestDayHistory =
        allHistory.where((h) => isSameDay(h.date, latestDate)).toList();

    
    
    final List<_RecentHistoryDisplay> displayRows = latestDayHistory.map((h) {
      final workoutName =
          workoutNamesById[h.workoutId] ?? 'Workout #${h.workoutId}';

      return _RecentHistoryDisplay(
        workoutName: workoutName,
        exerciseId: h.exerciseId,
        date: h.date,
        sets: h.sets,
        notes: h.notes,
      );
    }).toList();

    return displayRows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Session'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<_RecentHistoryDisplay>>(
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

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text('No workout history yet.'),
            );
          }

          final String sessionWorkoutName = entries.first.workoutName;
          final DateTime sessionDate = entries.first.date;
          final String sessionDateText =
              '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Text(
                  '$sessionWorkoutName ($sessionDateText)',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ...entries.map((entry) {
                  final String setsSummary =
                      entry.sets.isEmpty ? '-' : entry.sets.join(', ');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exercise ID: ${entry.exerciseId}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Sets: $setsSummary',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        if (entry.notes != null && entry.notes!.isNotEmpty)
                          Text(
                            'Notes: ${entry.notes}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
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
