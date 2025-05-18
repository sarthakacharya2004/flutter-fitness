import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nutrition plans categorized by user goals
  final Map<String, List<Map<String, dynamic>>> _goalNutrition = {
    'Lose Weight': [
      {
        'title': 'Low-Calorie Breakfast',
        'calories': '300 kcal',
        'time': '15 min',
        'protein': '20g',
        'category': 'Breakfast',
        'image': 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        'recipe': [
          'Greek yogurt',
          'Berries',
          'Honey',
          'Granola',
        ].join('\n'),
      },
      {
        'title': 'Lean Protein Lunch',
        'calories': '400 kcal',
        'time': '20 min',
        'protein': '35g',
        'category': 'Lunch',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'recipe': [
          'Grilled chicken breast',
          'Mixed vegetables',
          'Quinoa',
          'Light dressing',
        ].join('\n'),
      },
    ],
    'Maintain': [
      {
        'title': 'Balanced Breakfast',
        'calories': '450 kcal',
        'time': '15 min',
        'protein': '25g',
        'category': 'Breakfast',
        'image': 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        'recipe': [
          'Oatmeal',
          'Banana',
          'Nuts',
          'Milk',
        ].join('\n'),
      },
      {
        'title': 'Balanced Lunch',
        'calories': '550 kcal',
        'time': '25 min',
        'protein': '30g',
        'category': 'Lunch',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'recipe': [
          'Turkey sandwich',
          'Mixed salad',
          'Fruit',
          'Yogurt',
        ].join('\n'),
      },
    ],
    'Gain Muscles': [
      {
        'title': 'High-Calorie Breakfast',
        'calories': '700 kcal',
        'time': '20 min',
        'protein': '40g',
        'category': 'Breakfast',
        'image': 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        'recipe': [
          'Protein pancakes',
          'Eggs',
          'Peanut butter',
          'Banana',
        ].join('\n'),
      },
      {
        'title': 'Muscle Building Lunch',
        'calories': '800 kcal',
        'time': '30 min',
        'protein': '50g',
        'category': 'Lunch',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'recipe': [
          'Steak',
          'Sweet potato',
          'Broccoli',
          'Olive oil',
        ].join('\n'),
      },
    ],
  };

  /// Returns nutrition plan for the provided goal
  List<Map<String, dynamic>> getNutritionByGoal(String goal) {
    return _goalNutrition[goal] ?? [];
  }

  /// Update user's selected goal in Firestore
  Future<void> updateUserGoal(String userId, String newGoal) async {
    try {
      await _firestore.collection('users').doc(userId).update({'goal': newGoal});
    } catch (e) {
      debugPrint('Error updating goal: $e');
    }
  }

  /// Retrieve user's current goal from Firestore
  Future<String?> getUserGoal(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['goal'] as String?;
    } catch (e) {
      debugPrint('Error fetching goal: $e');
      return null;
    }
  }

  /// Get all available goals
  List<String> getAllGoals() {
    return _goalNutrition.keys.toList();
  }
}
