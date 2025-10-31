// Mid-workout Exercise View Screen
import 'package:flutter/material.dart';
class ExerciseViewScreen extends StatelessWidget {
  const ExerciseViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mid Workout Exercise'),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Next Exercise Button'),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Text(
              '[Exercise Name]',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: const Text(
              '[Exercise Demonstration]',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Previous Weight: # weight'),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Weight (lbs):'),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '[Textbox to enter weight]',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
               Text('Number of sets:'),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '[# sets]',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('Repetitions:'),
                 Text('[Placeholder text for current weight]'),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('[Textbox to enter reps]'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('[Textbox to enter reps]'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('[Textbox to enter reps]'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Skip for now'),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Home'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Exercises'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Workouts'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}