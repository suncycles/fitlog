import 'package:flutter/material.dart';

import '../class/accessor_functions.dart';
import '../class/history_class.dart';
import '../class/workout_class.dart';
import '../class/exercise_class.dart'; 

class _RecentHistoryDisplay {
  final String workoutName;
  final String exerciseName;
  final DateTime date;
  final List<String> sets;
  final String? notes;

  _RecentHistoryDisplay({
    required this.workoutName,
    required this.exerciseName,
    required this.date,
    required this.sets,
    this.notes,
  });
}

class RecentSessionScreen extends StatelessWidget {
  const RecentSessionScreen({super.key});

  /// Load the most recent workout session across all workouts
  Future<List<_RecentHistoryDisplay>> _loadRecentSession() async {
    final db = WorkoutDatabase.instance;

    //map names to ids
    final List<Exercise?> allExercises = await db.getExercises();
    final Map<int, String> exerciseNamesById = {};
    for (final e in allExercises) {
      if (e != null && e.id != null && e.name.isNotEmpty) {
        exerciseNamesById[e.id!] = e.name;
      }
    }
    
    // fetch workout list from db for mapping id to workout name
    final List<Workout> workouts = await db.getWorkouts();
    if (workouts.isEmpty) return [];

    final Map<int, String> workoutNamesById = {};
    for (final w in workouts) {
      if (w.id != null) {
        workoutNamesById[w.id!] = w.name;
      }
    }

    // fetch history from db
    final List<ExerciseHistory> allHistory = [];
    for (final workout in workouts) {
      final workoutId = workout.id;
      if (workoutId == null) continue;

      final historyForWorkout = await db.getExerciseHistory(workoutId);
      allHistory.addAll(historyForWorkout);
    }

    if (allHistory.isEmpty) return [];

    // find the latest day
    allHistory.sort((a, b) => b.date.compareTo(a.date));
    final DateTime latestDate = allHistory.first.date;

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final List<ExerciseHistory> latestDayHistory =
        allHistory.where((h) => isSameDay(h.date, latestDate)).toList();

    final List<_RecentHistoryDisplay> displayRows = latestDayHistory.map((h) {
      final workoutName =
          workoutNamesById[h.workoutId] ?? 'Workout #${h.workoutId}';
      
      final exerciseName = 
          exerciseNamesById[h.exerciseId] ?? 'Exercise ID: ${h.exerciseId}';

      return _RecentHistoryDisplay(
        workoutName: workoutName,
        exerciseName: exerciseName,
        date: h.date,
        sets: h.sets,
        notes: h.notes,
      );
    }).toList();
    
    // sort by workout name first (to group them), then by date/time
    displayRows.sort((a, b) {
      int nameComparison = a.workoutName.compareTo(b.workoutName);
      if (nameComparison != 0) return nameComparison;
      return a.date.compareTo(b.date); 
    });

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

          final DateTime sessionDate = entries.first.date;
          final String sessionDateText =
              '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}';

          String? lastWorkoutName; 
          final List<Widget> children = [];
          
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
              child: Text(
                'History for $sessionDateText',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          );
          
          // iterate over entries and add the workout title
          for (final entry in entries) {
            if (entry.workoutName != lastWorkoutName) {
              children.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                  child: Text(
                    entry.workoutName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
              lastWorkoutName = entry.workoutName;
            }
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _ExerciseHistoryTile(
                  exerciseName: entry.exerciseName,
                  sets: entry.sets,
                  notes: entry.notes,
                ),
              ),
            );
          }


          return ListView(
            children: children,
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

class _ExerciseHistoryTile extends StatelessWidget {
  final String exerciseName;
  final List<String> sets; // Format: "WeightxReps"
  final String? notes;

  const _ExerciseHistoryTile({
    required this.exerciseName,
    required this.sets,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exerciseName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8.0, 
            runSpacing: 4.0, 
            children: sets.map((setStr) {
              final parts = setStr.split('x');
              final weight = parts.isNotEmpty ? parts[0] : 'N/A';
              final reps = parts.length > 1 ? parts[1] : 'N/A';

              return Chip(
                label: Text(
                  '$reps reps @ $weight lbs',
                  style: const TextStyle(fontSize: 14),
                ),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              );
            }).toList(),
          ),

          if (notes != null && notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Notes: ${notes!}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}