import 'package:flutter/material.dart';
import 'package:fitness_hub/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupStepsScreen extends StatefulWidget {
  const SignupStepsScreen({super.key});

  @override
  _SignupStepsScreenState createState() => _SignupStepsScreenState();
}

class _SignupStepsScreenState extends State<SignupStepsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _weightGoalController = TextEditingController();
  String? selectedGoal;
  int step = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _nextStep() async {
    setState(() {
      if (step == 1 && _weightController.text.isNotEmpty && _weightGoalController.text.isNotEmpty) {
        step = 2;
      } else if (step == 2 && selectedGoal != null) {
        _saveUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete the selection")),
        );
      }
    });
  }

  void _saveUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'weight': double.parse(_weightController.text),
          'goal': selectedGoal,
          'startWeight': double.parse(_weightController.text),
          'weightGoal': double.parse(_weightGoalController.text),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Navigate to HomeScreen and pass the weight
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                initialWeight: double.parse(_weightController.text),
                userGoal: selectedGoal!,
                weightGoal: double.parse(_weightGoalController.text),
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personalize Your Experience")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: step / 2),
            const SizedBox(height: 20),
            if (step == 1) ...[
              const Text("Enter Your Body Weight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Current Weight in kg",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Enter Your Goal Weight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _weightGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Goal Weight in kg",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else if (step == 2) ...[
              const Text("Select Your Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
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
                child: Text(step == 2 ? "Finish" : "Next", style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBox(String goal) {
    return GestureDetector(
      onTap: () => setState(() => selectedGoal = goal),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selectedGoal == goal ? Colors.blue.shade100 : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(goal, style: const TextStyle(fontSize: 16)),
            if (selectedGoal == goal) const Icon(Icons.check, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}