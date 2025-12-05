import 'package:flutter/material.dart';
import 'package:fitlog/screens/root_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'LiftLog',
      home: RootScreen(), // Show Root screen, will be either first pikcup or home
    );
  }
}