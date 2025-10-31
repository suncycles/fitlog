import 'package:flutter/material.dart';

class RecentSessionScreen extends StatelessWidget {
  const RecentSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example workout data
    final List<Map<String, dynamic>> exercises = [
      {'name': 'Exercise 1', 'weight': 200, 'sets': 3, 'reps': 12},
      {'name': 'Exercise 2', 'weight': 205, 'sets': 3, 'reps': 10},
      {'name': 'Exercise 3', 'weight': 190, 'sets': 3, 'reps': 12},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Session'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Workout Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Build each exercise entry
            ...exercises.map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${exercise['name']}:  Weight: ${exercise['weight']} lbs',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '${exercise['sets']} Sets of ${exercise['reps']} Reps',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),

      // Simple navigation bar at the bottom (optional)
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // Go back to home
          }
        },
      ),
    );
  }
}
