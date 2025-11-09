import 'package:flutter/material.dart';
//import 'body_screen.dart';
//import 'exercise_view_screen.dart';
import 'home_screen.dart';
import 'view_workouts_list_screen.dart';
import 'exercise_view_screen.dart';
import 'body_screen.dart';

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
  // Text controller and current search query
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Hard code data, replace with data in database later
  static const List<_CategoryData> _Categories = [
    _CategoryData(title: 'Quad', exerciseCount: '# of exercises'),
    _CategoryData(title: 'Chest', exerciseCount: '# of exercises'),
    _CategoryData(title: 'Arm', exerciseCount: '# of exercises'),
  ];

  /*
  Returns a list of categories based on the current query sentence.

  Args:
    none

  Returns:
    type: List<_CategoryData>, a list of matched muscle group categories
  */
  List<_CategoryData> get _results {
    if (_query.isEmpty) {
      return _Categories;
    }
    final String queryLowercase = _query.toLowerCase(); // For case-insensitive
    return _Categories.where((category) => category.title.toLowerCase().contains(queryLowercase)).toList();
  }

  /*
  Updates the 'query' and show the new filtered list.

  Args:
    none

  Returns:
    type: void
  */
  void _doSearch() {
    setState(() {
      _query = _searchController.text.trim();
    });
  }

  /*
  Disposes resources of the TextEditingController.

  Args:
    none

  Returns:
    type: void
  */
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for ...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _doSearch,
                ),
                if (_query.isNotEmpty || _searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search results list
          if (_results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No results found', style: TextStyle(color: Colors.black54)),
              ),
            )
          else
            ..._results.expand((category) => [
              _CategoryCard(title: category.title, exerciseCount: category.exerciseCount),
              const SizedBox(height: 16),
            ]),
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

// Fake class of categories, will replace later
class _CategoryData {
  final String title;
  final String exerciseCount;
  const _CategoryData({required this.title, required this.exerciseCount});
}