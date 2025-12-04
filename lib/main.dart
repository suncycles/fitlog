import 'package:fitlog/class/workout_class.dart';
import 'package:fitlog/screens/view_workouts_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitlog/screens/home_screen.dart';
import 'db_test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
