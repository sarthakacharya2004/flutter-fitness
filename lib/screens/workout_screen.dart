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
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWorkoutHeader(),
                    const SizedBox(height: 20),
                    Text(
                      'Workout Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _workoutCategories.map((category) {
                        return _buildCategoryItem(category);
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Recommended Workouts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._recommendedWorkouts.map((workout) {
                      return _buildWorkoutCard(workout);
                    }).toList(),
                    const SizedBox(height: 20),
                  ],
                ),
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Workouts',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, size: 40, color: Colors.blue),
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
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        color: category['color'],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category['icon'], size: 32, color: category['iconColor']),
          const SizedBox(height: 8),
          Text(
            category['name'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
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
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              workout['image'],
              width: double.infinity,
              height: 150,
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildWorkoutInfoChip(Icons.timer_outlined, workout['duration']),
                    const SizedBox(width: 8),
                    _buildWorkoutInfoChip(Icons.flash_on_outlined, workout['difficulty']),
                    const SizedBox(width: 8),
                    _buildWorkoutInfoChip(Icons.local_fire_department_outlined, '${workout['calories']} Cal'),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
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
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.blue[100] : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
