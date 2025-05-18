import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NutritionPlan {
  final String title;
  final String calories;
  final String time;
  final String protein;
  final String category;
  final String image;
  final String recipe;

  NutritionPlan({
    required this.title,
    required this.calories,
    required this.time,
    required this.protein,
    required this.category,
    required this.image,
    required this.recipe,
  });

  factory NutritionPlan.fromMap(Map<String, dynamic> map) {
    return NutritionPlan(
      title: map['title'],
      calories: map['calories'],
      time: map['time'],
      protein: map['protein'],
      category: map['category'],
      image: map['image'],
      recipe: map['recipe'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'calories': calories,
      'time': time,
      'protein': protein,
      'category': category,
      'image': image,
      'recipe': recipe,
    };
  }
}

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _cachedGoal; // Caching goal for session performance

  final Map<String, List<NutritionPlan>> _goalNutrition = {
    'Lose Weight': [
      NutritionPlan(
        title: 'Low-Calorie Breakfast',
        calories: '300 kcal',
        time: '15 min',
        protein: '20g protein',
        category: 'Breakfast',
        image: 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        recipe: '1. Greek yogurt\n2. Berries\n3. Honey\n4. Granola',
      ),
      NutritionPlan(
        title: 'Lean Protein Lunch',
        calories: '400 kcal',
        time: '20 min',
        protein: '35g protein',
        category: 'Lunch',
        image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        recipe: '1. Grilled chicken breast\n2. Mixed vegetables\n3. Quinoa\n4. Light dressing',
      ),
    ],
    'Maintain': [
      NutritionPlan(
        title: 'Balanced Breakfast',
        calories: '450 kcal',
        time: '15 min',
        protein: '25g protein',
        category: 'Breakfast',
        image: 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        recipe: '1. Oatmeal\n2. Banana\n3. Nuts\n4. Milk',
      ),
      NutritionPlan(
        title: 'Balanced Lunch',
        calories: '550 kcal',
        time: '25 min',
        protein: '30g protein',
        category: 'Lunch',
        image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        recipe: '1. Turkey sandwich\n2. Mixed salad\n3. Fruit\n4. Yogurt',
      ),
    ],
    'Gain': [
      NutritionPlan(
        title: 'High-Calorie Breakfast',
        calories: '700 kcal',
        time: '20 min',
        protein: '40g protein',
        category: 'Breakfast',
        image: 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55',
        recipe: '1. Protein pancakes\n2. Eggs\n3. Peanut butter\n4. Banana',
      ),
      NutritionPlan(
        title: 'Muscle Building Lunch',
        calories: '800 kcal',
        time: '30 min',
        protein: '50g protein',
        category: 'Lunch',
        image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        recipe: '1. Steak\n2. Sweet potato\n3. Broccoli\n4. Olive oil',
      ),
    ],
  };

  List<NutritionPlan> getNutritionByGoal(String goal) {
    return _goalNutrition[goal] ?? [];
  }

  Future<void> updateUserGoal(String userId, String newGoal) async {
    await _firestore.collection('users').doc(userId).update({
      'goal': newGoal,
    });
    _cachedGoal = newGoal; // update cache
  }

  Future<String> getUserGoal(String userId) async {
    if (_cachedGoal != null) return _cachedGoal!;
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    final goal = doc.get('goal') as String;
    _cachedGoal = goal;
    return goal;
  }
}
