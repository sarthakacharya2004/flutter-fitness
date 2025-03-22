import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../routes/routes.dart';

class BodyWeightScreen extends StatefulWidget {
  @override
  _BodyWeightScreenState createState() => _BodyWeightScreenState();
}

class _BodyWeightScreenState extends State<BodyWeightScreen> {
  final TextEditingController _weightController = TextEditingController();

  void _continue() {
    if (_weightController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BodyGoalScreen(weight: _weightController.text)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your weight")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Your Body Weight")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Weight in kg"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _continue,
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

class BodyGoalScreen extends StatelessWidget {
  final String weight;
  BodyGoalScreen({required this.weight});

  void _selectGoal(BuildContext context, String goal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DietPreferenceScreen(weight: weight, goal: goal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Your Goal")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => _selectGoal(context, "Bulk"), child: Text("Bulk")),
            ElevatedButton(onPressed: () => _selectGoal(context, "Shredded"), child: Text("Shredded")),
            ElevatedButton(onPressed: () => _selectGoal(context, "Lean"), child: Text("Lean")),
            ElevatedButton(onPressed: () => _selectGoal(context, "Maintain"), child: Text("Maintain")),
          ],
        ),
      ),
    );
  }
}

class DietPreferenceScreen extends StatelessWidget {
  final String weight;
  final String goal;
  DietPreferenceScreen({required this.weight, required this.goal});

  void _selectDiet(BuildContext context, String diet) {
    Navigator.pushNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose Your Diet Preference")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => _selectDiet(context, "Vegetarian"), child: Text("Vegetarian")),
            ElevatedButton(onPressed: () => _selectDiet(context, "Non-Vegetarian"), child: Text("Non-Vegetarian")),
          ],
        ),
      ),
    );
  }
}
