import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_workouts_list_screen.dart';
import 'search_screen.dart';
import 'recent_session_screen.dart';
import 'exercise_progress_screen.dart';
import 'first_pickup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Default username
  String _userName = 'Joe';

  List<Widget> get _screens => [
        _HomepagePanel(userName: _userName),
        const SearchScreen(),
        const WorkoutsListScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('user_name');
    
    if (stored != null && stored.isNotEmpty) {
      if (mounted) {
        setState(() => _userName = stored);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Exercises'),
          NavigationDestination(icon: Icon(Icons.view_list), label: 'Workouts'),
        ],
      ),
    );
  }
}

class _HomepagePanel extends StatelessWidget {
  final String userName;

  const _HomepagePanel({required this.userName});

  @override
  Widget build(BuildContext context) {
    const Color startButtonColor = Color.fromARGB(255, 174, 214, 168);
    const Color cardColor = Color.fromARGB(255, 215, 214, 214);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,\n$userName',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 24),

            // Start Workout Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutsListScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: startButtonColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Start Workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // View Progress Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExerciseProgressScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'View Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Recent Session Button
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecentSessionScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recent Session',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}