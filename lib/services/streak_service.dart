import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int _streakIncrementValue = 10;
  final int _streakGoal = 20;
  // Add a constant for the maximum workouts per day to increment streak
  final int _maxWorkoutsPerDay = 2;

  String? get _userId => _auth.currentUser?.uid;
  bool get isUserLoggedIn => _userId != null;

  DocumentReference? get _streakRef {
    if (_userId != null) {
      return _firestore.collection('user_streaks').doc(_userId);
    }
    return null;
  }

  //Get Streak from firebase or shared preferences
  Future<int> _getStreakFromSource() async {
    if (isUserLoggedIn) {
      final docSnapshot = await _streakRef!.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['current_streak'] ?? 0;
      } else {
        // Initialize the user's streak data in Firestore.  Make sure to include ALL fields.
        await _streakRef!.set({
          'current_streak': 0,
          'daily_streak': 0,
          'last_workout_date': null,
          'streak_goal': _streakGoal,
          'streak_increment': _streakIncrementValue,
          'total_streak': 0, // Initialize total_streak here
          'updated_at': FieldValue.serverTimestamp(),
        });
        return 0;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('workout_streak') ?? 0;
    }
  }

  //get total streak from firebase or shared preferences
    Future<int> _getTotalStreakFromSource() async {
    if (isUserLoggedIn) {
      final docSnapshot = await _streakRef!.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['total_streak'] ?? 0;
      } else {
        return 0;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('total_streak') ?? 0;
    }
  }

  Future<int> getCurrentStreak() async {
    try {
      return await _getStreakFromSource();
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
    int dailyWorkouts = await getDailyWorkouts(); //get daily workout

    bool isWorkoutToday = false;
    bool isConsecutiveDay = false;

    if (lastWorkoutDate != null) {
      int daysDifference = now.difference(lastWorkoutDate).inDays;
      String lastWorkoutDateString =
          "${lastWorkoutDate.year}-${lastWorkoutDate.month}-${lastWorkoutDate.day}";
      isWorkoutToday = (lastWorkoutDateString == today);
      isConsecutiveDay = (daysDifference == 1);
    }

    // Initialize or get total streak
    int totalStreak = await _getTotalStreakFromSource();
    totalStreak += incrementBy; // Increment total streak

    // Handle current streak updates
    if (isWorkoutToday) {
      // Increment daily workout count
      dailyWorkouts += 1;

      // Only increment current streak for the first N workouts per day
      if (dailyWorkouts <= _maxWorkoutsPerDay) {
        currentStreak += _streakIncrementValue;
        currentStreak = currentStreak.clamp(0, _streakGoal);
      }
      await prefs.setInt('daily_workouts', dailyWorkouts);
    } else {
      // It's a new day
      if (isConsecutiveDay) {
        // Continue streak from previous day
        currentStreak += _streakIncrementValue;
      } else {
        // Start a new streak
        currentStreak = _streakIncrementValue;
      }
      currentStreak = currentStreak.clamp(0, _streakGoal);
      // Reset daily workouts counter for the new day
      await prefs.setInt('daily_workouts', 1);
    }

    //save the streak
    await _saveStreak(currentStreak: currentStreak, totalStreak: totalStreak, lastWorkoutDate: now);
  } catch (e) {
    debugPrint('Error updating streak: $e');
  }
}
  //save streak
  Future<void> _saveStreak({required int currentStreak, required int totalStreak, required DateTime lastWorkoutDate}) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workout_streak', currentStreak);
    await prefs.setString('last_workout_date', "${lastWorkoutDate.year}-${lastWorkoutDate.month}-${lastWorkoutDate.day}");
    await prefs.setInt('total_streak', totalStreak);
     if (isUserLoggedIn) {
      await _streakRef!.set({
        'current_streak': currentStreak,
        'last_workout_date': lastWorkoutDate,
        'total_streak': totalStreak,
        'streak_goal': _streakGoal,
        'streak_increment': _streakIncrementValue,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>> getStreakInfo() async {
    int currentStreak = await getCurrentStreak();
    final prefs = await SharedPreferences.getInstance();
    int dailyStreak = prefs.getInt('daily_streak') ?? 0;
    int totalStreak = await _getTotalStreakFromSource();

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
          'total_streak': 0, // Reset total streak
          'streak_goal': _streakGoal,
          'streak_increment': _streakIncrementValue,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('workout_streak', 0);
      await prefs.setInt('daily_streak', 0);
      await prefs.remove('last_workout_date');
      await prefs.setInt('total_streak', 0); // Reset total streak in shared preferences
      await prefs.setInt('daily_workouts', 0);
    } catch (e) {
      debugPrint('Error resetting streak: $e');
    }
  }
}