import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Screen'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Nutrition Plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  NutritionCard(
                      meal: 'Breakfast', details: 'Oatmeal with fruits'),
                  NutritionCard(
                      meal: 'Lunch',
                      details: 'Grilled chicken with vegetables'),
                  NutritionCard(meal: 'Dinner', details: 'Salmon with quinoa'),
                  NutritionCard(
                      meal: 'Snack', details: 'Greek yogurt with nuts'),
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meal Plan Updated!')),
                  );
                },
                child: const Text('Update Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionCard extends StatelessWidget {
  final String meal;
  final String details;

  const NutritionCard({required this.meal, required this.details, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(meal,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: Text(details, style: const TextStyle(fontSize: 16)),
        leading: const Icon(Icons.restaurant, color: Colors.green),
      ),
    );
  }
}
