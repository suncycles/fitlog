import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';

class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => BodyScreenState();
}

class BodyScreenState extends State<BodyScreen> {
  BodyParts _bodyParts = const BodyParts();

  Future<String> fetchBodyPartInfo(dynamic part) async {
    return 'dummy function';
  }

  void onBodyPartSelected(BodyParts updatedParts) async {
    setState(() => _bodyParts = updatedParts);

    String data = await fetchBodyPartInfo(updatedParts);

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Selected Body Part"),
        content: Text(data),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Body Selector")),
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