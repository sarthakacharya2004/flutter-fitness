import 'package:fitness_hub/services/streak_service.dart';
import 'package:fitness_hub/services/goal_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';
import 'workout_detail_screen.dart';


class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  // Static method to update streak - now using the streak service
  static Future<void> updateStreak() async {
    // Create instance of streak service and update streak
    final streakService = StreakService();
    await streakService.updateStreak(incrementBy: 10);
  }

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

