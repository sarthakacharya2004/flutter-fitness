import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new meal to Firestore
  Future<void> addMeal(Map<String, dynamic> mealData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meals')
            .add(mealData);
      }
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  // Get all meals
  Stream<List<Map<String, dynamic>>> getMeals() {
    final user = _auth.currentUser;
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

  // Update a meal
  Future<void> updateMeal(String mealId, Map<String, dynamic> updatedData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meals')
            .doc(mealId)
            .update(updatedData);
      }
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  // Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meals')
            .doc(mealId)
            .delete();
      }
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  Future<void> addWeightLog(Map<String, dynamic> weightData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final todayDate = DateTime.now();
        final formattedDate = '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

        final weightRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('weight_logs')
            .doc(formattedDate);

        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userSnapshot = await userDocRef.get();

        // ✅ Set start weight only if not already present
        if (!userSnapshot.exists || !userSnapshot.data()!.containsKey('start_weight')) {
          await userDocRef.set({'start_weight': weightData['weight']}, SetOptions(merge: true));
        }

        await weightRef.set({
          ...weightData,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add weight log: $e');
    }
  }

  // Get the weight log for today
  Stream<Map<String, dynamic>?> getWeightLogForToday() {
    final user = _auth.currentUser;
    if (user != null) {
      final todayDate = DateTime.now();
      final formattedDate = '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

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

  // Update the weight log for today
  Future<void> updateWeightLog(Map<String, dynamic> updatedData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final todayDate = DateTime.now();
        final formattedDate = '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}';

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('weight_logs')
            .doc(formattedDate)
            .update(updatedData);
      }
    } catch (e) {
      throw Exception('Failed to update weight log: $e');
    }
  }

  // Fetch all weight logs (sorted by timestamp)
  Future<List<Map<String, dynamic>>> getAllWeightLogs() async {
  final user = _auth.currentUser;
  if (user == null) return [];

  try {
    final query = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('weight_logs')
        .where('timestamp', isGreaterThan: Timestamp(0, 0)) // ✅ Filters out documents without a timestamp
        .orderBy('timestamp') // ✅ Sorts by timestamp
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print('Error occurred while fetching weight logs: $e');
    return [];
  }
}


  // Fetch the start weight from Firestore
  Future<DocumentSnapshot> getStartWeight() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection('users').doc(user.uid).get();
    }
    throw Exception('No user logged in');
  }

  Future<Map<String, double?>> getStartAndCurrentWeight() async {
    final user = _auth.currentUser;
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
