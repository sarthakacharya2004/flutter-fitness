import 'package:flutter/material.dart';
import 'package:fitness_hub/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupStepsScreen extends StatefulWidget {
  const SignupStepsScreen({super.key});

  @override
  State<SignupStepsScreen> createState() => _SignupStepsScreenState();
}

class _SignupStepsScreenState extends State<SignupStepsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _weightGoalController = TextEditingController();
  String? selectedGoal;
  int step = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
void _nextStep() {
  final weightText = _weightController.text.trim();
  final goalWeightText = _weightGoalController.text.trim();

  if (step == 1) {
    final currentWeight = double.tryParse(weightText);
    final goalWeight = double.tryParse(goalWeightText);

    if (weightText.isEmpty || goalWeightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    if (currentWeight == null || goalWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid numeric values.")),
      );
      return;
    }

    if (currentWeight <= 0 || goalWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Weights must be greater than zero.")),
      );
      return;
    }

    setState(() => step = 2);
  } else if (step == 2) {
    if (selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a goal before continuing.")),
      );
      return;
    }

    _saveUserData();
  }
}


void _saveUserData() async {
  final weightText = _weightController.text.trim();
  final weightGoalText = _weightGoalController.text.trim();

  final weight = double.tryParse(weightText);
  final weightGoal = double.tryParse(weightGoalText);

  if (weight == null || weightGoal == null || selectedGoal == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please provide valid weight and goal values.")),
    );
    return;
  }

  final User? user = _auth.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in.")),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await _firestore.collection('users').doc(user.uid).set({
      'weight': weight,
      'startWeight': weight,
      'weightGoal': weightGoal,
      'goal': selectedGoal,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    Navigator.pop(context); // close loading indicator

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          initialWeight: weight,
          userGoal: selectedGoal!,
          weightGoal: weightGoal,
        ),
      ),
    );
  } catch (e) {
    Navigator.pop(context); // close loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save data: ${e.toString()}")),
    );
  }
}


 void _previousStep() {
  if (step > 1) {
    setState(() => step--);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You are already at the first step.")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personalize Your Experience"),
        leading: step > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: step / 2,
              backgroundColor: Colors.grey[200],
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            if (step == 1) ...[
              _buildLabel("Enter Your Body Weight"),
              _buildNumberField("Current Weight in kg", _weightController),
              const SizedBox(height: 20),
              _buildLabel("Enter Your Goal Weight"),
              _buildNumberField("Goal Weight in kg", _weightGoalController),
            ] else if (step == 2) ...[
              _buildLabel("Select Your Goal"),
              _buildSelectionBox("Lose Weight"),
              _buildSelectionBox("Maintain"),
              _buildSelectionBox("Gain Muscles"),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _nextStep,
                child: Text(step == 2 ? "Finish" : "Next",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionBox(String goal) {
    final isSelected = selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => selectedGoal = goal),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(goal, style: const TextStyle(fontSize: 16)),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
