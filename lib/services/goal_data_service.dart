import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GoalDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Store or update the user's goal in Firestore.
  Future<void> storeUserGoal(String userId, String goal) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'goal': goal,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error storing user goal: $e');
      rethrow;
    }
  }

  /// Retrieve the user's goal from Firestore. Returns 'general' if not found.
  Future<String> getUserGoal(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['goal'] as String? ?? 'general';
    } catch (e) {
      debugPrint('Error getting user goal: $e');
      return 'general';
    }
  }

  /// Fetch workouts matching the user's goal.
  Future<List<Map<String, dynamic>>> getWorkoutsByGoal(String goal) async {
    try {
      final query = await _firestore
          .collection('workouts')
          .where('goal', isEqualTo: goal)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
      return [];
    }
  }

  /// Fetch nutrition plans matching the user's goal.
  Future<List<Map<String, dynamic>>> getNutritionByGoal(String goal) async {
    try {
      final query = await _firestore
          .collection('nutrition')
          .where('goal', isEqualTo: goal)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error fetching nutrition: $e');
      return [];
    }
  }
}
