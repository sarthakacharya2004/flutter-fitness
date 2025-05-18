import 'package:cloud_firestore/cloud_firestore.dart';

class GoalDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeGoalData(String userId, String goal) async {
    await _firestore.collection('users').doc(userId).set({
      'goal': goal,
    }, SetOptions(merge: true));
  }

  Future<String> getUserGoal(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection('users').doc(userId).get();
    return doc.data()?['goal'] ?? 'general';
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByGoal(String goal) async {
    final query =
        await _firestore.collection('workouts').where('goal', isEqualTo: goal).get();
    return query.docs.map((snapshot) => snapshot.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getNutritionByGoal(String goal) async {
    final query =
        await _firestore.collection('nutrition').where('goal', isEqualTo: goal).get();
    return query.docs.map((snapshot) => snapshot.data()).toList();
  }
}
