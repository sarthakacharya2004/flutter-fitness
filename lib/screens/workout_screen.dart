import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<Map<String, dynamic>> _workoutCategories = [
    {
      'name': 'Strength',
      'icon': Icons.fitness_center,
      'color': Colors.red[100],
      'iconColor': Colors.red,
    },
    {
      'name': 'Cardio',
      'icon': Icons.directions_run,
      'color': Colors.blue[100],
      'iconColor': Colors.blue,
    },
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'color': Colors.green[100],
      'iconColor': Colors.green,
    },
    {
      'name': 'HIIT',
      'icon': Icons.timeline,
      'color': Colors.purple[100],
      'iconColor': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _recommendedWorkouts = [
    {
      'title': 'Full Body Workout',
      'duration': '45 mins',
      'difficulty': 'Intermediate',
      'image': 'assets/full-body.png',
      'calories': 350,
    },
    {
      'title': 'Core Strength',
      'duration': '30 mins',
      'difficulty': 'Beginner',
      'image': 'assets/core-workout.png',
      'calories': 250,
    },
    {
      'title': 'High Intensity Interval',
      'duration': '25 mins',
      'difficulty': 'Advanced',
      'image': 'assets/hiit-workout.png',
      'calories': 400,
    },
  ];

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildWorkoutHeader(),
                  _buildWorkoutCategories(),
                  _buildRecommendedWorkouts(),
                ],
              ),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Workouts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.blue, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Your Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep logging your workouts to see improvements',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Workout Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _workoutCategories.map((category) {
                return _buildCategoryItem(category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: category['color'],
            child: Icon(
              category['icon'],
              color: category['iconColor'],
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category['name'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedWorkouts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Workouts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...(_recommendedWorkouts.map((workout) {
            return _buildWorkoutCard(workout);
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              workout['image'],
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildWorkoutInfoChip(
                      Icons.timer_outlined, 
                      workout['duration']
                    ),
                    const SizedBox(width: 8),
                    _buildWorkoutInfoChip(
                      Icons.flash_on_outlined, 
                      workout['difficulty']
                    ),
                    const SizedBox(width: 8),
                    _buildWorkoutInfoChip(
                      Icons.local_fire_department_outlined, 
                      '${workout['calories']} Cal'
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Start workout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, false, () {
            _navigateToScreen(context, const HomeScreen());
          }),
          _buildNavBarItem(Icons.list, false, () {
            _navigateToScreen(context, const NutritionScreen());
          }),
          _buildNavBarItem(Icons.fitness_center, true, () {}),
          _buildNavBarItem(Icons.person, false, () {
            _navigateToScreen(context, const ProfileScreen());
          }),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: isActive ? Colors.black : Colors.grey,
      ),
    );
  }
}