import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class WaterIntakeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String get _userId => _auth.currentUser!.uid;

  /// Save water intake for today (overwrites existing entry)
  Future<void> saveWaterIntake(double intakeInLiters) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';

    // Get previous intake for comparison
    final previousIntake = await getTodayWaterIntake();
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('waterIntake')
        .doc(dateKey)
        .set({
      'intake': intakeInLiters,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Create notification for water intake update
    final difference = intakeInLiters - previousIntake;
    if (difference > 0) {
      await _notificationService.createActivityNotification(
        'Water',
        'added ${difference.toStringAsFixed(1)}L of water intake',
      );
    }
  }

  /// Get today's water intake
  Future<double> getTodayWaterIntake() async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';

    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('waterIntake')
        .doc(dateKey)
        .get();

    if (doc.exists && doc.data() != null) {
      return (doc.data()!['intake'] as num).toDouble();
    } else {
      return 0.0;
    }
  }

  /// Get last 7 days of water intake (including today)
  Future<List<double>> getLast7DaysIntake(double dailyGoal) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 6));
    
    try {
      // Get all water intake records for the last 7 days in a single query
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('waterIntake')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('timestamp', descending: true)
          .get();

      // Create a map of date to intake for easy lookup
      final Map<String, double> intakeMap = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp;
        final date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
        final dateKey = '${date.year}-${date.month}-${date.day}';
        intakeMap[dateKey] = (data['intake'] as num).toDouble();
      }

      // Build the history list with proper ordering
      List<double> history = [];
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final key = '${day.year}-${day.month}-${day.day}';
        history.add(intakeMap[key] ?? 0.0);
      }

      return history;
    } catch (e) {
      print('Error fetching water intake history: $e');
      return List.filled(7, 0.0);
    }
  }
}
