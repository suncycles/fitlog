import 'package:flutter/material.dart';
//import 'body_screen.dart';
//import 'exercise_view_screen.dart';
import 'home_screen.dart';
import 'view_workouts_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _ExercisesPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}

class _ExercisesPanel extends StatefulWidget {
  const _ExercisesPanel({super.key});

  @override
  State<_ExercisesPanel> createState() => _ExercisesPanelState();
}

class _ExercisesPanelState extends State<_ExercisesPanel> {
  @override
  Widget build(BuildContext context) {
    const Color bodyViewColor = Color.fromARGB(255, 239, 83, 81);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Exercises Title
              const Expanded(
                child: Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
              //Body View Button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BodyScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bodyViewColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Body View',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          //Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 227, 235, 250),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for ...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          //Muscle Groups
          const _CategoryCard(title: 'Quad', exerciseCount: '# of exercises'),
          const SizedBox(height: 16),
          const _CategoryCard(title: 'Chest', exerciseCount: '# of exercises'),
          const SizedBox(height: 16),
          const _CategoryCard(title: 'Arm', exerciseCount: '# of exercises'),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({super.key, required this.title, required this.exerciseCount});

  final String title;
  final String exerciseCount;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color.fromARGB(255, 217, 217, 217);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Muscle Group Title
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                //Number of Exercises
                Text(
                  widget.exerciseCount,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          Column(
            children: [
              // Image
              Container(
                width: 100,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Image'),
              ),
              const SizedBox(height: 12),
              //Exercises Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExerciseViewScreen()),
                  );
                },
                child: const Text('Browse All'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}