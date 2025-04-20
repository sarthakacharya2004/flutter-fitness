import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWeekly = false;
  int _waterIntake = 0;
  final int _waterGoal = 2000;
  bool _goalMet = false;

  final Map<String, int> dailyStats = {
    'Calories': 2600,
    'Protein': 180,
    'Carbs': 260,
    'Fat': 80,
  };

  final List<Map<String, dynamic>> workoutGoals = [
    {'title': 'Push-ups', 'reps': '50 reps', 'icon': Icons.fitness_center},
    {'title': 'Running', 'reps': '5 km', 'icon': Icons.directions_run},
    {'title': 'Squats', 'reps': '30 reps', 'icon': Icons.accessibility_new},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(context),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Nutrition Section
                    _buildNutritionSection(),

                    const SizedBox(height: 16),

                    // Water & Workout Section
                    _buildWaterWorkoutSection(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  // ====================== Section Builders ======================
  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/profile_image.png'),
              ),
              const SizedBox(width: 12),
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeToggle(),
        ],
      ),
    );
  }

  Widget _buildTimeToggle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleButton('Today', !showWeekly, () {
              setState(() => showWeekly = false);
            }),
            _buildToggleButton('Weekly', showWeekly, () {
              setState(() => showWeekly = true);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: dailyStats.entries.map((entry) {
              return _buildNutritionCard(
                entry.key,
                entry.value.toString(),
                _getUnitForTitle(entry.key),
                _getBgColor(entry.key),
                _getTextColor(entry.key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterWorkoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Water Intake Section
          _buildWaterIntakeSection(),

          const SizedBox(height: 16),

          // Workout Section
          _buildWorkoutGoalsSection(),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeSection() {
    double progress = _waterIntake / _waterGoal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Water Intake',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _goalMet ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_waterIntake}ml',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/${_waterGoal}ml',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_goalMet)
                    const Text(
                      'Goal Met!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaterButton(Icons.remove, () {
                setState(() {
                  _waterIntake = (_waterIntake - 250).clamp(0, _waterGoal);
                  _goalMet = _waterIntake >= _waterGoal;
                });
              }),
              const SizedBox(width: 24),
              _buildWaterButton(Icons.add, () {
                setState(() {
                  _waterIntake = (_waterIntake + 250).clamp(0, _waterGoal);
                  _goalMet = _waterIntake >= _waterGoal;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Workout",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workoutGoals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final workout = workoutGoals[index];
            return _buildWorkoutCard(
              workout['title'],
              workout['reps'],
              workout['icon'],
            );
          },
        ),
      ],
    );
  }

  // ====================== Component Builders ======================
  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
      String title, String value, String unit, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForTitle(title),
                  color: textColor,
                  size: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.blue),
      ),
    );
  }

  Widget _buildWorkoutCard(String title, String reps, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                reps,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(Icons.home_filled, true, () {}),
          _buildNavButton(Icons.list, false, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NutritionScreen()));
          }),
          _buildNavButton(Icons.fitness_center, false, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WorkoutScreen()));
          }),
          _buildNavButton(Icons.person, false, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isActive ? Colors.black : Colors.grey,
        size: 24,
      ),
    );
  }

  // ====================== Helper Methods ======================
  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Calories':
        return Icons.local_fire_department;
      case 'Protein':
        return Icons.fitness_center;
      case 'Carbs':
        return Icons.rice_bowl;
      case 'Fat':
        return Icons.fastfood;
      default:
        return Icons.info;
    }
  }

  String _getUnitForTitle(String title) {
    switch (title) {
      case 'Calories':
        return 'kcal';
      case 'Protein':
      case 'Carbs':
      case 'Fat':
        return 'g';
      default:
        return '';
    }
  }

  Color _getBgColor(String title) {
    switch (title) {
      case 'Calories':
        return Colors.orange.shade50;
      case 'Protein':
        return Colors.blue.shade800;
      case 'Carbs':
        return Colors.green.shade600;
      case 'Fat':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String title) {
    switch (title) {
      case 'Protein':
      case 'Carbs':
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}
