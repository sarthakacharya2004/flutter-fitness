import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random();

  // Track last notification times
  DateTime? _lastWorkoutNotification;
  DateTime? _lastWaterNotification;

  // Check workout completion status
  Future<bool> _isWorkoutCompleted() async {
    if (_auth.currentUser == null) return true;

    final workoutDoc = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('date', isEqualTo: DateTime.now().toString().split(' ')[0])
        .get();

    return workoutDoc.docs.isNotEmpty;
  }

  // Check water intake status
  Future<bool> _isWaterGoalMet() async {
    if (_auth.currentUser == null) return true;

    final waterDoc = await _firestore
        .collection('water_intake')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('date', isEqualTo: DateTime.now().toString().split(' ')[0])
        .get();

    if (waterDoc.docs.isEmpty) return false;
    final data = waterDoc.docs.first.data();
    return (data['current'] ?? 0) >= (data['goal'] ?? 2000);
  }

  // Create activity notification
  Future<void> createActivityNotification(String activity, String detail) async {
    await createNotification(
      activity,
      customTitle: 'Activity Update',
      customMessage: 'You $detail',
    );
  }

  // Check and create scheduled notifications
  Future<void> checkScheduledNotifications() async {
    final now = DateTime.now();

    // Check workout notification (every 4 hours)
    if (_lastWorkoutNotification == null ||
        now.difference(_lastWorkoutNotification!).inHours >= 4) {
      final workoutCompleted = await _isWorkoutCompleted();
      if (!workoutCompleted) {
        await createNotification('Workout');
        _lastWorkoutNotification = now;
      }
    }

    // Check water intake notification (every 4 hours)
    if (_lastWaterNotification == null ||
        now.difference(_lastWaterNotification!).inHours >= 4) {
      final waterGoalMet = await _isWaterGoalMet();
      if (!waterGoalMet) {
        await createNotification('Water');
        _lastWaterNotification = now;
      }
    }
  }

  // Workout motivation messages
  final List<String> _workoutMessages = [
    "Time to crush those fitness goals! 💪",
    "Your future self will thank you for working out today! 🎯",
    "Ready to turn those dreams into gains? Let's go! 🔥",
    "Missing your workout? Your body misses you too! 🏃‍♂️",
    "Feeling lazy? Remember why you started! 💭",
    "Your workout is calling - time to answer! 📱"
  ];

  // Water reminder messages
  final List<String> _waterMessages = [
    "Staying hydrated is your superpower! 💧",
    "Time for a water break - your body will thank you! 🌊",
    "Feeling tired? Maybe you need some water! 💦",
    "Keep calm and drink water! 🚰",
    "Water is life - time for a refill! 🥤",
    "Your plants get water daily, shouldn't you? 🌱"
  ];

  // Meal reminder messages
  final List<String> _mealMessages = [
    "Time to fuel your body with goodness! 🥗",
    "Hungry yet? Your next healthy meal awaits! 🍽️",
    "Don't skip meals - your body needs the energy! 🔋",
    "Meal prep hero, it's your time to shine! 👩‍🍳",
    "Your body deserves good food - what's on the menu? 📋",
    "Healthy eating made fun - let's do this! 🥑"
  ];

  String _getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  Future<void> createNotification(String type, {String? customTitle, String? customMessage}) async {
    if (_auth.currentUser == null) return;

    String message = customMessage ?? '';
    String title = customTitle ?? '';

    if (customMessage == null) {
      switch (type) {
        case 'Workout':
          message = _getRandomMessage(_workoutMessages);
          title = 'Workout Reminder';
          break;
        case 'Water':
          message = _getRandomMessage(_waterMessages);
          title = 'Hydration Check';
          break;
        case 'Meals':
          message = _getRandomMessage(_mealMessages);
          title = 'Meal Time';
          break;
        case 'Profile':
          title = 'Profile Update';
          break;
      }
    }

    await _firestore.collection('notifications').add({
      'userId': _auth.currentUser!.uid,
      'type': type,
      'title': title,
      'message': message,
      'time': DateTime.now().toString(),
      'unread': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'unread': false});
  }

  Future<void> markAllAsRead() async {
    if (_auth.currentUser == null) return;

    QuerySnapshot notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('unread', isEqualTo: true)
        .get();

    WriteBatch batch = _firestore.batch();
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'unread': false});
    }
    await batch.commit();
  }

  Future<void> clearAllMessages() async {
    if (_auth.currentUser == null) return;
  
    QuerySnapshot notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .get();
  
    WriteBatch batch = _firestore.batch();
    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}