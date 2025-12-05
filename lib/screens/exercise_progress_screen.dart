import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../class/accessor_functions.dart'; 
import '../class/history_class.dart';
import '../class/workout_class.dart';

class ProgressRecord {
  final int exerciseId;
  final String exerciseName;
  final double maxWeight; 
  final DateTime date;

  ProgressRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeight,
    required this.date,
  });
}

class ExerciseProgressScreen extends StatefulWidget {
  const ExerciseProgressScreen({super.key});

  @override
  State<ExerciseProgressScreen> createState() => ExerciseProgressScreenState();
}

class ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  Map<String, int> _exerciseNameMap = {'All Exercises': 0}; 
  String selectedExercise = 'All Exercises';
  List<ProgressRecord> records = [];
  bool isLoading = true;
  double personalRecord = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  // only load exercises that would show up in recent session (exercises the user has ever done)
  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    final db = WorkoutDatabase.instance;
    final List<Workout> workouts = await db.getWorkouts();
    final Set<int> performedExerciseIds = {};
    
    // get exercise ids
    for (final w in workouts) {
      if (w.id != null) {
        final historyForWorkout = await db.getExerciseHistory(w.id!);
        for (final history in historyForWorkout) {
          performedExerciseIds.add(history.exerciseId);
        }
      }
    }
    
    // map ids to names
    final Map<String, int> nameMap = {'All Exercises': 0};
    
    for (final id in performedExerciseIds) {
      final exercise = await db.getExercise(id);
      if (exercise != null && exercise.name.isNotEmpty && exercise.id != null) {
        nameMap[exercise.name] = exercise.id!;
      }
    }
    
    setState(() {
      _exerciseNameMap = nameMap;
      if (!_exerciseNameMap.containsKey(selectedExercise)) {
        selectedExercise = 'All Exercises';
      }
    });

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      records = [];
    });

    try {
      final data = await _fetchAndParseProgress();
      
      List<ProgressRecord> filteredData;
      if (selectedExercise == 'All Exercises') {
        filteredData = _getTop5Exercises(data);
      } else {
        filteredData = data.where((r) => r.exerciseName == selectedExercise).toList();
      }

      setState(() {
        records = filteredData;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading progress data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<ProgressRecord>> _fetchAndParseProgress() async {
    final db = WorkoutDatabase.instance;
    final List<Workout> workouts = await db.getWorkouts();
    final Map<int, List<ExerciseHistory>> historyByWorkout = {};
    
    for (final w in workouts) {
      if (w.id != null) {
        historyByWorkout[w.id!] = await db.getExerciseHistory(w.id!);
      }
    }
    
    final Map<String, Map<String, double>> dailyMaxes = {}; // key: ExerciseName -> DateString -> MaxWeight

    for (final workoutId in historyByWorkout.keys) {
      for (final history in historyByWorkout[workoutId]!) {
        double maxWeightForSession = 0.0;
        
        for (final setStr in history.sets) {
          final parts = setStr.split('x');
          if (parts.length >= 1) {
            final weight = double.tryParse(parts[0]) ?? 0.0;
            if (weight > maxWeightForSession) {
              maxWeightForSession = weight;
            }
          }
        }
        
        if (maxWeightForSession == 0.0) continue;

        // find the exercise name from the map
        final exerciseName = _exerciseNameMap.entries
            .firstWhere(
              (e) => e.value == history.exerciseId, 
              orElse: () => const MapEntry('', 0)
            ).key;

        if (exerciseName.isNotEmpty && exerciseName != 'All Exercises') {
          final dateString = '${history.date.year}-${history.date.month}-${history.date.day}';
          
          dailyMaxes.putIfAbsent(exerciseName, () => {});
          
          final currentMax = dailyMaxes[exerciseName]![dateString] ?? 0.0;
          if (maxWeightForSession > currentMax) {
            dailyMaxes[exerciseName]![dateString] = maxWeightForSession;
          }
        }
      }
    }

    // convert dailyMaxes back to ProgressRecord list
    final List<ProgressRecord> finalRecords = [];
    for (final exName in dailyMaxes.keys) {
      for (final dateString in dailyMaxes[exName]!.keys) {
        final parts = dateString.split('-').map(int.parse).toList();
        final maxWeight = dailyMaxes[exName]![dateString]!;
        final exerciseId = _exerciseNameMap[exName] ?? 0;

        finalRecords.add(ProgressRecord(
          exerciseId: exerciseId,
          exerciseName: exName,
          maxWeight: maxWeight,
          date: DateTime(parts[0], parts[1], parts[2]),
        ));
      }
    }
    
    finalRecords.sort((a, b) => a.date.compareTo(b.date));
    
    return finalRecords;
  }

  List<ProgressRecord> _getTop5Exercises(List<ProgressRecord> allRecords) {
    if (allRecords.isEmpty) return [];

    final counts = <String, int>{};
    for (var r in allRecords) {
      counts[r.exerciseName] = (counts[r.exerciseName] ?? 0) + 1;
    }

    final sortedNames = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    final top5Names = sortedNames.take(5).toSet();
    
    final top5Records = allRecords.where((r) => top5Names.contains(r.exerciseName)).toList();
    
    final Map<String, List<double>> dailyWeights = {};

    for (var r in top5Records) {
      final dateString = '${r.date.year}-${r.date.month}-${r.date.day}';
      dailyWeights.putIfAbsent(dateString, () => []);
      dailyWeights[dateString]!.add(r.maxWeight);
    }

    final List<ProgressRecord> synthesizedRecords = [];
    dailyWeights.forEach((dateString, weights) {
      final parts = dateString.split('-').map(int.parse).toList();
      final averageWeight = weights.reduce((a, b) => a + b) / weights.length;

      synthesizedRecords.add(ProgressRecord(
        exerciseId: 0,
        exerciseName: 'All Exercises Combined',
        maxWeight: averageWeight,
        date: DateTime(parts[0], parts[1], parts[2]),
      ));
    });
    
    synthesizedRecords.sort((a, b) => a.date.compareTo(b.date));
    return synthesizedRecords;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Progress'),
      ),
      body: Column(
        children: [
          // Exercise Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Exercise:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedExercise,
                    isExpanded: true,
                    items: _exerciseNameMap.keys
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedExercise = value;
                        });
                        _loadData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                      ? Center(child: Text('No progress data available for $selectedExercise.'))
                      : WeightProgressChart(records: records, exerciseName: selectedExercise),
            ),
          ),
        ],
      ),
    );
  }
}
// chart drawing widget
class WeightProgressChart extends StatelessWidget {
  final List<ProgressRecord> records;
  final String exerciseName;

  const WeightProgressChart({super.key, required this.records, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    final sortedRecords = records..sort((a, b) => a.date.compareTo(b.date));
    
    final spots = sortedRecords.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.maxWeight);
    }).toList();

    final minWeight = records.map((e) => e.maxWeight).reduce((a, b) => a < b ? a : b);
    final maxWeight = records.map((e) => e.maxWeight).reduce((a, b) => a > b ? a : b);
    
    final minY = (minWeight - (minWeight * 0.1)).floorToDouble();
    final maxY = (maxWeight + (maxWeight * 0.1)).ceilToDouble();
    
    final range = maxY - minY;
    final interval = range > 100 ? 50.0 : range > 50 ? 25.0 : range > 20 ? 10.0 : 5.0;

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Date (Weeks)'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, 
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedRecords.length) {
                  if (value.toInt() % 4 == 0 || sortedRecords.length < 5) {
                    final date = sortedRecords[value.toInt()].date;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8.0,
                      child: Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10)),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Max Weight (lbs)'),
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: interval,
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
        minX: 0,
        maxX: (sortedRecords.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueAccent.withOpacity(0.3),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final record = sortedRecords[touchedSpot.x.toInt()];
                return LineTooltipItem(
                  '${record.maxWeight.toStringAsFixed(1)} lbs\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '${record.date.month}/${record.date.day}/${record.date.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}