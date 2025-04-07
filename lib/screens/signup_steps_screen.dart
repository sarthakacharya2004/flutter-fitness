import 'package:flutter/material.dart';
import 'package:fitness_hub/screens/home_screen.dart';

class SignupStepsScreen extends StatefulWidget {
  const SignupStepsScreen({super.key});

  @override
  _SignupStepsScreenState createState() => _SignupStepsScreenState();
}

class _SignupStepsScreenState extends State<SignupStepsScreen> {
  final TextEditingController _weightController = TextEditingController();
  String? selectedGoal;
  String? selectedDiet;
  int step = 1;

  void _nextStep() {
    setState(() {
      if (step == 1 && _weightController.text.isNotEmpty) {
        step = 2;
      } else if (step == 2 && selectedGoal != null) {
        step = 3;
      } else if (step == 3 && selectedDiet != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete the selection")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personalise Your Experience")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: step / 3),
            const SizedBox(height: 20),
            if (step == 1) ...[
              const Text("Enter Your Body Weight", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Weight in kg",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else if (step == 2) ...[
              const Text("Select Your Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildSelectionBox("Shredded"),
              _buildSelectionBox("Lean"),
              _buildSelectionBox("Bulk"),
              _buildSelectionBox("Muscular"),
            ] else if (step == 3) ...[
              const Text("Choose Your Diet Preference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildDietSelection("Vegetarian"),
              _buildDietSelection("Non-Vegetarian"),
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
                child: Text(step == 3 ? "Finish" : "Next", style: const TextStyle(fontSize: 16, color: Colors.white)),
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

  Widget _buildDietSelection(String diet) {
    return GestureDetector(
      onTap: () => setState(() => selectedDiet = diet),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selectedDiet == diet ? Colors.blue.shade100 : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(diet, style: const TextStyle(fontSize: 16)),
            if (selectedDiet == diet) const Icon(Icons.check, color: Colors.blue),
          ],
        ),
     ),
);
}
}