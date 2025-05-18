import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GoalDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 /// Stores or updates the user's goal in Firestore with validation and error logging.
Future<void> storeUserGoal(String userId, String goal) async {
  if (userId.isEmpty || goal.isEmpty) {
    debugPrint('Invalid userId or goal provided.');
    return;
  }

  try {
    await _firestore.collection('users').doc(userId).set(
      {'goal': goal},
      SetOptions(merge: true),
    );
    debugPrint('User goal updated successfully for userId: $userId');
  } catch (e, stackTrace) {
    debugPrint('Failed to store user goal: $e');
    debugPrintStack(stackTrace: stackTrace);
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
