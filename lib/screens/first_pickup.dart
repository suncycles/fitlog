import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class FirstPickUp extends StatefulWidget {
  const FirstPickUp({super.key});

  @override
  State<FirstPickUp> createState() => _FirstPickUpState();
}

class _FirstPickUpState extends State<FirstPickUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Dropdown selections
  String? fitnessLevel;
  String? preferredExercise;

  // Default weight unit
  String weightUnit = 'kg';

  // Dropdown lists
  final List<String> fitnessLevels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> exercises = ['Cardio', 'Strength', 'Yoga', 'Pilates'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WELCOME to LiftLog'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Please fill out the below fields',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),

              // Name input
              const Text('Name:'),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Age input
              const Text('Age:'),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter your age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Weight input with unit selector
              const Text('Weight:'),
              Row(
                children: [
                  // Weight value
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter your weight',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Weight unit dropdown
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: weightUnit,
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'lb', child: Text('lb')),
                      ],
                      onChanged: (value) {
                        setState(() => weightUnit = value!);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Fitness level dropdown
              const Text('Fitness Level:'),
              DropdownButtonFormField<String>(
                value: fitnessLevel,
                items: fitnessLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => fitnessLevel = value);
                },
                decoration: const InputDecoration(
                  hintText: 'Select fitness level',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Preferred exercise dropdown
              const Text('Preferred Exercises:'),
              DropdownButtonFormField<String>(
                value: preferredExercise,
                items: exercises
                    .map((exercise) => DropdownMenuItem(
                          value: exercise,
                          child: Text(exercise),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => preferredExercise = value);
                },
                decoration: const InputDecoration(
                  hintText: 'Select preferred exercise',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("That's okay! We'll guide you 💪"),
                      ),
                    );
                  },
                  child: const Text("I don't know"),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: () async {
                    // Print entered data for debugging
                    //print('Name: ${nameController.text}');
                    //print('Age: ${ageController.text}');
                    //print('Weight: ${weightController.text} $weightUnit');
                    //print('Fitness: $fitnessLevel');
                    //print('Exercise: $preferredExercise');

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('user_name', nameController.text.trim());

                    if (!context.mounted) return;
                    Navigator.pushReplacement( 
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Done",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
