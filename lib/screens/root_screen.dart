import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'first_pickup.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}
// checks which screen to display on launch, first pickup or home.
class _RootScreenState extends State<RootScreen> {
  late Future<bool> _isFirstLaunch;

  @override
  void initState() {
    super.initState();
    _isFirstLaunch = _checkFirstLaunch();
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name');
    return userName == null || userName.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstLaunch,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('An error occurred loading preferences.'),
            ),
          );
        } else {
          final isFirstLaunch = snapshot.data ?? true; 
          
          if (isFirstLaunch) {
            return const FirstPickUp();
          } else {
            return const HomeScreen();
          }
        }
      },
    );
  }
}