import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nutrition plans based on goals 
  final Map<String, List<Map<String, dynamic>>> _goalNutrition = {
    'Lose Weight': [
      {
        'title': 'Low-Calorie Breakfast',
        'calories': '300 kcal',
        'time': '15 min',
        'protein': '20g protein',
        'category': 'Breakfast',
        'image': 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        'recipe': '1. Greek yogurt\n2. Berries\n3. Honey\n4. Granola',
      },
      {
        'title': 'Lean Protein Lunch',
        'calories': '400 kcal',
        'time': '20 min',
        'protein': '35g protein',
        'category': 'Lunch',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'recipe': '1. Grilled chicken breast\n2. Mixed vegetables\n3. Quinoa\n4. Light dressing',
      },
    ],
    'Maintain': [
      {
        'title': 'Balanced Breakfast',
        'calories': '450 kcal',
        'time': '15 min',
        'protein': '25g protein',
        'category': 'Breakfast',
        'image': 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        'recipe': '1. Oatmeal\n2. Banana\n3. Nuts\n4. Milk',
      },
      {
        'title': 'Balanced Lunch',
        'calories': '550 kcal',
        'time': '25 min',
        'protein': '30g protein',
        'category': 'Lunch',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'recipe': '1. Turkey sandwich\n2. Mixed salad\n3. Fruit\n4. Yogurt',
      },
    ],
    'Gain': [
      {
        'title': 'High-Calorie Breakfast',
        'calories': '700 kcal',
        'time': '20 min',
        'protein': '40g protein',
        'category': 'Breakfast',
        'image': 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        'recipe': '1. Protein pancakes\n2. Eggs\n3. Peanut butter\n4. Banana',
      },
      {
        'title': 'Muscle Building Lunch',
        'calories': '800 kcal',
        'time': '30 min',
        'protein': '50g protein',
        'category': 'Lunch',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'recipe': '1. Steak\n2. Sweet potato\n3. Broccoli\n4. Olive oil',
      },
    ],
  };

  // Get nutrition plans for specific goal
  List<Map<String, dynamic>> getNutritionByGoal(String goal) {
    return _goalNutrition[goal] ?? [];
  }

  // Update user's goal in Firestore
  Future<void> updateUserGoal(String userId, String newGoal) async {
    await _firestore.collection('users').doc(userId).update({
      'goal': newGoal,
    });
  }

  // Get user's current goal
  Future<String> getUserGoal(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.get('goal') as String;
  }
}
