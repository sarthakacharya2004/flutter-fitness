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

  /// Get today’s water intake
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
    List<double> history = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('waterIntake')
          .doc(key)
          .get();

      if (doc.exists && doc.data() != null) {
        history.add((doc.data()!['intake'] as num).toDouble());
      } else {
        history.add(0.0); // No data = 0 intake
      }
    }

    return history;
  }
}
