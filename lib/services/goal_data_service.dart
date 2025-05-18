import 'package:cloud_firestore/cloud_firestore.dart';

class GoalDataService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references for easier reuse
  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _workoutsCollection =>
      _firestore.collection('workouts');
  CollectionReference<Map<String, dynamic>> get _nutritionCollection =>
      _firestore.collection('nutrition');

  // Store or update user's goal in Firestore (merge true to not overwrite other fields)
  Future<void> storeGoalData(String userId, String goal) async {
    await _userCollection.doc(userId).set({
      'goal': goal,
    }, SetOptions(merge: true));
  }

  // Fetch user's current goal from Firestore
  Future<String> getUserGoal(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _userCollection.doc(userId).get();
    return doc.data()?['goal'] ?? 'general'; // Default to 'general' if not set
  }

  // Get list of workouts filtered by the user's goal
  Future<List<Map<String, dynamic>>> getWorkoutsByGoal(String goal) async {
    final QuerySnapshot<Map<String, dynamic>> query =
        await _workoutsCollection.where('goal', isEqualTo: goal).get();
    return query.docs.map((snapshot) => snapshot.data()).toList();
  }

  // Get list of nutrition plans filtered by the user's goal
  Future<List<Map<String, dynamic>>> getNutritionByGoal(String goal) async {
    final QuerySnapshot<Map<String, dynamic>> query =
        await _nutritionCollection.where('goal', isEqualTo: goal).get();
    return query.docs.map((snapshot) => snapshot.data()).toList();
  }
}
