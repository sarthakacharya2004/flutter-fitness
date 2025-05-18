import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get current user or null if not signed in
  User? _getCurrentUser() => _auth.currentUser;

  String _getFormattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> addMeal(Map<String, dynamic> mealData) async {
    try {
      final user = _getCurrentUser();
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meals')
            .add(mealData);
      }
    } catch (e) {
      print('Error adding meal: $e');
      throw Exception('Failed to add meal: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getMeals() {
    final user = _getCurrentUser();
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meals')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList());
    }
    return const Stream.empty();
  }

  Future<void> updateMeal(String mealId, Map<String, dynamic> updatedData) async {
    try {
      final user = _getCurrentUser();
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meals')
            .doc(mealId)
            .update(updatedData);
      }
    } catch (e) {
      print('Error updating meal: $e');
      throw Exception('Failed to update meal: $e');
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      final user = _getCurrentUser();
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meals')
            .doc(mealId)
            .delete();
      }
    } catch (e) {
      print('Error deleting meal: $e');
      throw Exception('Failed to delete meal: $e');
    }
  }

  Future<void> addWeightLog(Map<String, dynamic> weightData) async {
    try {
      final user = _getCurrentUser();
      if (user != null) {
        final formattedDate = _getFormattedDate(DateTime.now());

        final weightRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('weight_logs')
            .doc(formattedDate);

        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userSnapshot = await userDocRef.get();

        if (!userSnapshot.exists || !userSnapshot.data()!.containsKey('start_weight')) {
          await userDocRef.set({'start_weight': weightData['weight']}, SetOptions(merge: true));
        }

        await weightRef.set({
          ...weightData,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding weight log: $e');
      throw Exception('Failed to add weight log: $e');
    }
  }

  Stream<Map<String, dynamic>?> getWeightLogForToday() {
    final user = _getCurrentUser();
    if (user != null) {
      final formattedDate = _getFormattedDate(DateTime.now());

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_logs')
          .doc(formattedDate)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists) {
              return snapshot.data() as Map<String, dynamic>;
            }
            return null;
          });
    }
    return Stream.value(null);
  }

  Future<void> updateWeightLog(Map<String, dynamic> updatedData) async {
    try {
      final user = _getCurrentUser();
      if (user != null) {
        final formattedDate = _getFormattedDate(DateTime.now());

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('weight_logs')
            .doc(formattedDate)
            .update(updatedData);
      }
    } catch (e) {
      print('Error updating weight log: $e');
      throw Exception('Failed to update weight log: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllWeightLogs() async {
    final user = _getCurrentUser();
    if (user == null) return [];

    try {
      final query = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_logs')
          .where('timestamp', isGreaterThan: Timestamp(0, 0))
          .orderBy('timestamp')
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching weight logs: $e');
      return [];
    }
  }

  Future<DocumentSnapshot> getStartWeight() async {
    final user = _getCurrentUser();
    if (user != null) {
      return await _firestore.collection('users').doc(user.uid).get();
    }
    throw Exception('No user logged in');
  }

  Future<Map<String, double?>> getStartAndCurrentWeight() async {
    final user = _getCurrentUser();
    if (user == null) return {'start': null, 'current': null};

    try {
      final logs = await getAllWeightLogs();
      final userSnapshot = await _firestore.collection('users').doc(user.uid).get();

      final startWeight = userSnapshot.data()?['start_weight']?.toDouble();
      final currentWeight = logs.isNotEmpty ? logs.last['weight']?.toDouble() : null;

      return {
        'start': startWeight,
        'current': currentWeight,
      };
    } catch (e) {
      print('Error fetching weights: $e');
      return {
        'start': null,
        'current': null,
      };
    }
  }
}
