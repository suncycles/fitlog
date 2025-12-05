import 'package:fitlog/class/accessor_functions.dart';
import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';
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
      print('Available muscle groups in database: $muscles');
    } catch (e) {
      print('Error loading muscles: $e');
    }
  }

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

  String? _mapBodyPartToMuscle(BodyParts bodyParts) {
    
    _getSelectedParts(bodyParts);
    
    if (bodyParts.head) return 'neck';
    if (bodyParts.neck) return 'neck';
    
    if (bodyParts.leftShoulder || bodyParts.rightShoulder) return 'shoulders';
    
    if (bodyParts.leftUpperArm || bodyParts.rightUpperArm) {
      return 'biceps';
    }
    
    if (bodyParts.leftLowerArm || bodyParts.rightLowerArm) return 'forearms';
    if (bodyParts.leftElbow || bodyParts.rightElbow) return 'forearms';
    
    if (bodyParts.leftHand || bodyParts.rightHand) return 'forearms';
    
    if (bodyParts.upperBody) return 'chest';
    if (bodyParts.abdomen) return 'abdominals';
    
    if (bodyParts.leftUpperLeg || bodyParts.rightUpperLeg) {
      return 'quadriceps';
    }
    
    if (bodyParts.leftLowerLeg || bodyParts.rightLowerLeg) return 'calves';
    if (bodyParts.leftKnee || bodyParts.rightKnee) return 'quadriceps';
    
    if (bodyParts.leftFoot || bodyParts.rightFoot) return 'calves';
    
    if (bodyParts.lowerBody) return 'abdominals';
    
    return null;
  }

  void onBodyPartSelected(BodyParts updatedParts) async {
    
    setState(() => _bodyParts = updatedParts);

    String? muscleGroup = _mapBodyPartToMuscle(updatedParts);
    
    if (muscleGroup == null) {
      //Clear selection
      if (mounted) {
        setState(() => _bodyParts = const BodyParts());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a body part'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    String? finalMuscleGroup = muscleGroup;
    
    if (_availableMuscles != null) {
      bool exactMatch = _availableMuscles!.any(
        (m) => m.toLowerCase() == muscleGroup.toLowerCase()
      );
      
      if (!exactMatch) {
        try {
          finalMuscleGroup = _availableMuscles!.firstWhere(
            (m) => m.toLowerCase().contains(muscleGroup.toLowerCase()) ||
                   muscleGroup.toLowerCase().contains(m.toLowerCase()),
          );
        } catch (e) {
          finalMuscleGroup = muscleGroup;
        }
      }
    }

    if (!mounted) return;

    // 3. Reset the state *before* navigation occurs
    setState(() {
      _bodyParts = const BodyParts();
    });

    // 4. Navigate to ExerciseListScreen
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