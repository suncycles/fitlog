// General View Exercise on Figmaimport 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:fitlog/class/accessor_functions.dart';
import 'package:fitlog/class/database_helper.dart';
import 'package:fitlog/class/exercise_class.dart';

class DbTest extends StatefulWidget {
  const DbTest({super.key});

  @override
  State<DbTest> createState() => _DbTestState();
}

class _DbTestState extends State<DbTest> {
  String result = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadExercise();
  }

  Future<void> loadExercise() async {
    String text = "hi";
    try {
      

      // Loading the database
      final db = await DatabaseHelper.instance.database;
    
      // Call accessor function to getExercise(id)
      Exercise? exercise = await WorkoutDatabase.instance.getExercise(1);

      if (exercise != null) {
        text = ("Name: ${exercise.name}");
      }
      setState(() {
        result = text;
        loading = false;
      });
      
      List<Exercise?> searchExercise = await WorkoutDatabase.instance.getExercises(primaryMuscle: null, search: 'Exercise Ball Pull-In');

      if (searchExercise != null) {
        for (var exercise in searchExercise) {
          if (exercise != null) {
            result = result + exercise.name;
          }
        }
      }
      else if (searchExercise == null) {
        result = "No exercises";
      }

      setState(() {
        this.result = result;
        loading = false;
      });

      List<String> primaryMuscles = await WorkoutDatabase.instance.getPrimaryMuscles();

      if (primaryMuscles != null) {
        for (var muscle in primaryMuscles) {
          result = result + muscle;
        }
      }

      setState(() {
        this.result = result;
        loading = false;
      });

      print("Success! Result: $text");
    } catch (e, stackTrace) {
      print("ERROR: $e");
      print("Stack trace: $stackTrace");
      
      setState(() {
        result = "Error: $e\n\nStack: $stackTrace";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DB Test')),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(result ?? 'No result'),
                ),
              ),
      ),
    );
  }
}


