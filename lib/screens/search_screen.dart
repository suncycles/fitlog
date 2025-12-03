import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'view_workouts_list_screen.dart';
import 'exercise_list_screen.dart';
import 'body_screen.dart';
import '../class/accessor_functions.dart';

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

  // Load all muscle groups from database
  List<String> _allMuscleGroups = [];
  // Filtered list shown in UI
  List<String> _uiMuscleGroups = [];

  bool _isLoading = true;

  /*
  Load the list of muscle groups from workoutDB, and exercise counts of each muscle group.

  Args:
    none

  Returns:
    type: Future<void>
  */
  Future<void> _loadMuscleGroups() async {
    final db = WorkoutDatabase.instance;
    final musclegroups = await db.getPrimaryMuscles();
    setState(() {
      _allMuscleGroups = musclegroups;
      _uiMuscleGroups = musclegroups;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMuscleGroups();
  }

  /*
  Updates '_query' and '_uiMuscleGroups' when the users search.

  Args:
    none

  Returns:
    type: void
  */
  void _doSearch() {
    setState(() {
      _query = _searchController.text.trim();
      if(_query.isEmpty) {
        _uiMuscleGroups = _allMuscleGroups;
      } else {
        final lowerQuery = _query.toLowerCase();
        _uiMuscleGroups = _allMuscleGroups.where((m) => m.toLowerCase().contains(lowerQuery)).toList();
      }
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
                    decoration: const InputDecoration(
                      hintText: 'Search for muscle group...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _doSearch,
                  tooltip: 'Search',
                ),
                if (_query.isNotEmpty || _searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {_query = ''; _uiMuscleGroups = _allMuscleGroups;});
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if(_isLoading)
            const Center(child: CircularProgressIndicator())
          else if(_uiMuscleGroups.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No muscle groups found', style: TextStyle(color: Colors.black54)),
              ),
            )
          else
            // Build one card per muscle group
            ..._uiMuscleGroups.expand(
              (muscle) => [
                _PrimaryMuscleCard(primaryMuscle: muscle),
                const SizedBox(height: 16),
              ]
            ),
        ],
      ),
    );
  }
}

/*
Card widget for one primary muscle in the list.

Includes:
- primary muscle name
- "# of exercises found"
- image
- "Browse All" button to go to ExerciseListScreen.
*/
class _PrimaryMuscleCard extends StatefulWidget {
  const _PrimaryMuscleCard({super.key, required this.primaryMuscle});

  final String primaryMuscle;

  @override
  State<_PrimaryMuscleCard> createState() => _PrimaryMuscleCardState();
}

class _PrimaryMuscleCardState extends State<_PrimaryMuscleCard> {
  int? _exerciseCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExerciseCount();
  }

  /*
  Loads the number of exercises of the primary muscles.

  Args:
    None

  Returns:
    Future<void>
  */
  Future<void> _loadExerciseCount() async {
    final db = WorkoutDatabase.instance;
    final count = await db.getExerciseCountForPrimaryMuscle(widget.primaryMuscle);
    if(!mounted) return;
    setState(() {
      _exerciseCount = count;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color.fromARGB(255, 217, 217, 217);

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 217, 217, 217),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name of muscle group and exercises count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.primaryMuscle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isLoading
                      ? '# of exercises'
                      : '${_exerciseCount ?? 0} exercises found',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Image and 'Browse All' button
          Column(
            children: [
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
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExerciseListScreen(primaryMuscle: widget.primaryMuscle),
                    ),
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