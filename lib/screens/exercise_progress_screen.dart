import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Dummy data models
class ExerciseRecord {
  final String exerciseName;
  final double weight;
  final DateTime date;

  ExerciseRecord({
    required this.exerciseName,
    required this.weight,
    required this.date,
  });
}

// Dummy database accessor
class ExerciseDatabase {
  static List<String> getExerciseNames() {
    return [
      'All Exercises',
      'Bench Press',
      'Squat',
      'Deadlift',
      'Overhead Press',
      'Barbell Row',
    ];
  }

  static List<ExerciseRecord> getExerciseRecords(String exerciseName) {
    // Generate dummy data for the past 12 weeks
    final records = <ExerciseRecord>[];
    final now = DateTime.now();
    
    if (exerciseName == 'All Exercises') {
      // Return mixed data
      for (int i = 0; i < 12; i++) {
        records.add(ExerciseRecord(
          exerciseName: 'Bench Press',
          weight: 135 + (i * 5) + (i % 3) * 2.5,
          date: now.subtract(Duration(days: 84 - (i * 7))),
        ));
      }
    } else {
      // Return specific exercise data
      final baseWeight = _getBaseWeight(exerciseName);
      for (int i = 0; i < 12; i++) {
        records.add(ExerciseRecord(
          exerciseName: exerciseName,
          weight: baseWeight + (i * 5) + (i % 3) * 2.5,
          date: now.subtract(Duration(days: 84 - (i * 7))),
        ));
      }
    }
    
    return records;
  }

  static double _getBaseWeight(String exerciseName) {
    switch (exerciseName) {
      case 'Bench Press':
        return 135;
      case 'Squat':
        return 185;
      case 'Deadlift':
        return 225;
      case 'Overhead Press':
        return 95;
      case 'Barbell Row':
        return 115;
      default:
        return 100;
    }
  }
}

class ExerciseProgressScreen extends StatefulWidget {
  const ExerciseProgressScreen({super.key});

  @override
  State<ExerciseProgressScreen> createState() => ExerciseProgressScreenState();
}

class ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  String selectedExercise = 'All Exercises';
  List<ExerciseRecord> records = [];
  double personalRecord = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = ExerciseDatabase.getExerciseRecords(selectedExercise);
    setState(() {
      records = data;
      personalRecord = data.isEmpty ? 0 : data.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    });
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
                    items: ExerciseDatabase.getExerciseNames()
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

          // PR Display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Personal Record:'),
                Text('${personalRecord.toStringAsFixed(1)} lbs'),
              ],
            ),
          ),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: records.isEmpty
                  ? const Center(child: Text('No data available'))
                  : WeightProgressChart(records: records),
            ),
          ),
        ],
      ),
    );
  }
}

class WeightProgressChart extends StatelessWidget {
  final List<ExerciseRecord> records;

  const WeightProgressChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final spots = records.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final minY = records.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 20;
    final maxY = records.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 20;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < records.length) {
                  final date = records[value.toInt()].date;
                  return Text('${date.month}/${date.day}');
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
        ),
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}