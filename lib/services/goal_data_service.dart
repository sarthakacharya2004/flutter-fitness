import 'package:cloud_firestore/cloud_firestore.dart';

class GoalDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _workoutsCollection =>
      _firestore.collection('workouts');
  CollectionReference<Map<String, dynamic>> get _nutritionCollection =>
      _firestore.collection('nutrition');

  Future<void> storeGoalData(String userId, String goal) async {
    await _userCollection.doc(userId).set({
      'goal': goal,
    }, SetOptions(merge: true));
  }

  Future<String> getUserGoal(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _userCollection.doc(userId).get();
    return doc.data()?['goal'] ?? 'general';
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByGoal(String goal) async {
    final query =
        await _workoutsCollection.where('goal', isEqualTo: goal).get();
    return query.docs.map((snapshot) => snapshot.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getNutritionByGoal(String goal) async {
    final query =
        await _nutritionCollection.where('goal', isEqualTo: goal).get();
    return query.docs.map((snapshot) => snapshot.data()).toList();
  }
}
