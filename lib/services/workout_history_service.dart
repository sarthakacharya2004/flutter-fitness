import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkoutHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save completed workout to history
  Future<void> saveWorkoutHistory({
    required String workoutName,
    required int duration,
    required int exercisesCompleted,
    required int caloriesBurned,
    String workoutType = 'general',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .add({
        'workout_name': workoutName,
        'duration': duration,
        'exercises_completed': exercisesCompleted,
        'calories_burned': caloriesBurned,
        'workout_type': workoutType,
        'date_completed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save workout history: $e');
    }
  }

  // Get all workout history
  Stream<List<Map<String, dynamic>>> getWorkoutHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workout_history')
        .orderBy('date_completed', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Get recent workouts (last 7 days)
  Future<List<Map<String, dynamic>>> getRecentWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final query = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .where('date_completed', isGreaterThan: Timestamp.fromDate(weekAgo))
          .orderBy('date_completed', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get recent workouts: $e');
    }
  }

  // Get total workout count
  Future<int> getTotalWorkoutsCompleted() async {
  final user = _auth.currentUser;
  if (user == null) return 0;

  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workout_history')
        .count()
        .get();

    return snapshot.count ?? 0; // Provide default value if count is null
  } catch (e) {
    debugPrint('Failed to get workout count: $e');
    return 0; // Return 0 in case of error
  }
}
}