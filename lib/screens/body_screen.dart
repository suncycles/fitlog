import 'package:fitlog/class/accessor_functions.dart';
import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';
import '../class/database_helper.dart';
import '../class/exercise_class.dart';
import 'exercise_list_screen.dart';

class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => BodyScreenState();
}

class BodyScreenState extends State<BodyScreen> {
  BodyParts _bodyParts = const BodyParts();
  List<String>? _availableMuscles;

  @override
  void initState() {
    super.initState();
    _loadAvailableMuscles();
  }

  Future<void> _loadAvailableMuscles() async {
    try {
      final muscles = await WorkoutDatabase.instance.getPrimaryMuscles();
      setState(() {
        _availableMuscles = muscles;
      });
      // Print available muscles to help with mapping
      print('Available muscle groups in database: $muscles');
    } catch (e) {
      print('Error loading muscles: $e');
    }
  }

  // Helper to get all selected body parts as a string for debugging
  String _getSelectedParts(BodyParts parts) {
    List<String> selected = [];
    
    if (parts.head) selected.add('head');
    if (parts.neck) selected.add('neck');
    if (parts.leftShoulder) selected.add('leftShoulder');
    if (parts.rightShoulder) selected.add('rightShoulder');
    if (parts.leftUpperArm) selected.add('leftUpperArm');
    if (parts.rightUpperArm) selected.add('rightUpperArm');
    if (parts.leftLowerArm) selected.add('leftLowerArm');
    if (parts.rightLowerArm) selected.add('rightLowerArm');
    if (parts.abdomen) selected.add('abdomen');
    if (parts.upperBody) selected.add('upperBody');
    if (parts.lowerBody) selected.add('lowerBody');
    if (parts.leftUpperLeg) selected.add('leftUpperLeg');
    if (parts.rightUpperLeg) selected.add('rightUpperLeg');
    if (parts.leftLowerLeg) selected.add('leftLowerLeg');
    if (parts.rightLowerLeg) selected.add('rightLowerLeg');
    
    print('Selected parts: ${selected.join(', ')}');
    return selected.join(', ');
  }

  // Map body parts to muscle groups
  String? _mapBodyPartToMuscle(BodyParts bodyParts) {
    
    _getSelectedParts(bodyParts);
    
    // Head and neck
    if (bodyParts.head) return 'neck';
    if (bodyParts.neck) return 'neck';
    
    // Shoulders
    if (bodyParts.leftShoulder || bodyParts.rightShoulder) return 'shoulders';
    
    // Upper arms
    if (bodyParts.leftUpperArm || bodyParts.rightUpperArm) {
      return 'biceps'; // Default to biceps
    }
    
    // Forearms
    if (bodyParts.leftLowerArm || bodyParts.rightLowerArm) return 'forearms';
    if (bodyParts.leftElbow || bodyParts.rightElbow) return 'forearms';
    
    // Hands
    if (bodyParts.leftHand || bodyParts.rightHand) return 'forearms';
    
    // Core/Torso
    if (bodyParts.upperBody) return 'chest';
    if (bodyParts.abdomen) return 'abdominals';
    
    // Legs - Upper leg contains quads, hamstrings, and glutes
    if (bodyParts.leftUpperLeg || bodyParts.rightUpperLeg) {
      // Default to quads
      return 'quadriceps';
    }
    
    // Lower legs
    if (bodyParts.leftLowerLeg || bodyParts.rightLowerLeg) return 'calves';
    if (bodyParts.leftKnee || bodyParts.rightKnee) return 'quadriceps';
    
    // Feet
    if (bodyParts.leftFoot || bodyParts.rightFoot) return 'calves';
    
    // Lower body general
    if (bodyParts.lowerBody) return 'abdominals';
    
    return null;
  }

  void onBodyPartSelected(BodyParts updatedParts) async {
    setState(() => _bodyParts = updatedParts);

    // Map the selected body part to a muscle group
    String? muscleGroup = _mapBodyPartToMuscle(updatedParts);
    
    if (muscleGroup == null) {
      // Show error message if no valid body part selected
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a body part'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Try to find exact or similar muscle group in database
    String? finalMuscleGroup = muscleGroup;
    
    if (_availableMuscles != null) {
      // Check if exact match exists
      bool exactMatch = _availableMuscles!.any(
        (m) => m.toLowerCase() == muscleGroup.toLowerCase()
      );
      
      if (!exactMatch) {
        // Try to find a similar muscle group name
        try {
          finalMuscleGroup = _availableMuscles!.firstWhere(
            (m) => m.toLowerCase().contains(muscleGroup.toLowerCase()) ||
                   muscleGroup.toLowerCase().contains(m.toLowerCase()),
          );
        } catch (e) {
          // No similar match found, use original
          finalMuscleGroup = muscleGroup;
        }
      }
    }

    if (!mounted) return;

    // Navigate to ExerciseListScreen with the selected muscle group
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListScreen(
          primaryMuscle: finalMuscleGroup!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Body Part Selector"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: BodyPartSelectorTurnable(
          bodyParts: _bodyParts,
          onSelectionUpdated: onBodyPartSelected,
          labelData: const RotationStageLabelData(
            front: 'Front',
            left: 'Left',
            right: 'Right',
            back: 'Back',
          ),
        ),
      ),
    );
  }
}