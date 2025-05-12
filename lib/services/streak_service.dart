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
      } else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getInt('workout_streak') ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting current streak: $e');
      return 0;
    }
  }


