import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int _streakIncrementValue = 10;
  final int _streakGoal = 20;

  String? get _userId => _auth.currentUser?.uid;
  bool get isUserLoggedIn => _userId != null;

  DocumentReference? get _streakRef {
    if (_userId != null) {
      return _firestore.collection('user_streaks').doc(_userId);
    }
    return null;
  }

  Future<int> getCurrentStreak() async {
    try {
      if (isUserLoggedIn) {
        final docSnapshot = await _streakRef!.get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          return data['current_streak'] ?? 0;
        } else {
          await _streakRef!.set({
            'current_streak': 0,
            'daily_streak': 0,
            'last_workout_date': null,
            'streak_goal': _streakGoal,
            'streak_increment': _streakIncrementValue,
            'updated_at': FieldValue.serverTimestamp(),
          });
          return 0;
        }
      }
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('workout_streak') ?? 0;
    } catch (e) {
      debugPrint('Error getting streak: $e');
      return 0;
    }
  }

  Future<DateTime?> getLastWorkoutDate() async {
    try {
      if (isUserLoggedIn) {
        final docSnapshot = await _streakRef!.get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final timestamp = data['last_workout_date'] as Timestamp?;
          return timestamp?.toDate();
        }
      }
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString('last_workout_date');
      return dateString != null ? DateTime.parse(dateString) : null;
    } catch (e) {
      debugPrint('Error getting last workout date: $e');
      return null;
    }
  }

  Future<int> getDailyWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('daily_workouts') ?? 0;
    } catch (e) {
      debugPrint('Error getting daily workouts: $e');
      return 0;
    }
  }

  Future<void> updateStreak({required int incrementBy}) async {
    try {
      DateTime now = DateTime.now();
      String today = "${now.year}-${now.month}-${now.day}";

      int currentStreak = await getCurrentStreak();
      DateTime? lastWorkoutDate = await getLastWorkoutDate();
      final prefs = await SharedPreferences.getInstance();

      bool isWorkoutToday = false;
      bool isConsecutiveDay = false;

if (lastWorkoutDate != null) {
  final lastDate = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
  final currentDate = DateTime(now.year, now.month, now.day);

  final daysDifference = currentDate.difference(lastDate).inDays;

  isWorkoutToday = (daysDifference == 0);
  isConsecutiveDay = (daysDifference == 1);
}

int totalStreak = 0;
if (isUserLoggedIn) {
  final docSnapshot = await _streakRef!.get();
  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    totalStreak = (data['total_streak'] ?? 0);
  }
} else {
  totalStreak = prefs.getInt('total_streak') ?? 0;
}

// Daily workout update
int dailyWorkouts = prefs.getInt('daily_workouts') ?? 0;

if (isWorkoutToday) {
  dailyWorkouts += 1;

  if (dailyWorkouts <= 2) {
    currentStreak += _streakIncrementValue;
    currentStreak = currentStreak.clamp(0, _streakGoal);
    totalStreak += _streakIncrementValue;
  }
} else {
  // New day
  dailyWorkouts = 1;

  if (isConsecutiveDay) {
    currentStreak += _streakIncrementValue;

        
        // Cap current streak at maximum value
        currentStreak = currentStreak.clamp(0, _streakGoal);
        
        // Reset daily workouts counter for the new day
        await prefs.setInt('daily_workouts', 1);
      }

      // Save the updated streak values
      await prefs.setInt('workout_streak', currentStreak);
      await prefs.setString('last_workout_date', today);
      await prefs.setInt('total_streak', totalStreak);

      // Update Firestore if user is logged in
      if (isUserLoggedIn) {
        await _streakRef!.set({
          'current_streak': currentStreak,
          'last_workout_date': now,
          'total_streak': totalStreak,
          'streak_goal': _streakGoal,
          'streak_increment': _streakIncrementValue,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  Future<Map<String, dynamic>> getStreakInfo() async {
    int currentStreak = await getCurrentStreak();
    final prefs = await SharedPreferences.getInstance();
    int dailyStreak = prefs.getInt('daily_streak') ?? 0;
    
    // Calculate total streak as current streak plus completed goals
    int totalStreak = currentStreak;
    if (isUserLoggedIn) {
      try {
        final docSnapshot = await _streakRef!.get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          // If total_streak exists in the database, use it, otherwise calculate it
          totalStreak = data['total_streak'] ?? currentStreak;
        }
      } catch (e) {
        debugPrint('Error getting total streak: $e');
      }
    }
    
    return {
      'current_streak': currentStreak,
      'daily_streak': dailyStreak,
      'total_streak': totalStreak,
      'streak_goal': _streakGoal,
      'streak_increment': _streakIncrementValue,
      'progress_percentage': _streakGoal > 0
          ? ((currentStreak % _streakGoal) / _streakGoal * 100)
          : 0,
      'total_goals_reached': (currentStreak / _streakGoal).floor(),
    };
  }

  Future<void> resetStreak() async {
    try {
      if (isUserLoggedIn) {
        await _streakRef!.set({
          'current_streak': 0,
          'daily_streak': 0,
          'last_workout_date': null,
          'reached_milestone': false,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('workout_streak', 0);
      await prefs.setInt('daily_streak', 0);
      await prefs.remove('last_workout_date');
      await prefs.setBool('reached_milestone', false);
      await prefs.setInt('daily_workouts', 0);
    } catch (e) {
      debugPrint('Error resetting streak: $e');
    }
  }
}