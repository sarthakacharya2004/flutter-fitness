import 'package:cloud_firestore/cloud_firestore.dart';

class GoalDataService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store or update the user's goal in Firestore (merging data)
  Future<void> storeGoalData(String userId, String goal) async {
    await _firestore.collection('users').doc(userId).set({
      'goal': goal,
    }, SetOptions(merge: true));
  }

  // Retrieve the user's current goal from Firestore, defaulting to 'general'
  Future<String> getUserGoal(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['goal'] ?? 'general';
  }

  // Get workouts that match the user's goal
  Future<List<Map<String, dynamic>>> getWorkoutsByGoal(String goal) async {
    final query = await _firestore.collection('workouts').where('goal', isEqualTo: goal).get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  // Get nutrition plans that match the user's goal
  Future<List<Map<String, dynamic>>> getNutritionByGoal(String goal) async {
    final query = await _firestore.collection('nutrition').where('goal', isEqualTo: goal).get();
    return query.docs.map((doc) => doc.data()).toList();
  }
}
