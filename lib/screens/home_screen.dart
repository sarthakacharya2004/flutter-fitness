import 'package:fitness_hub/screens/nutrition_screen.dart';
import 'package:fitness_hub/screens/profile_screen.dart';
import 'package:fitness_hub/screens/workout_screen.dart';
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
  bool showWeekly = false; // Toggle state for Today/Weekly

  // Daily Nutrition Stats
  final Map<String, int> dailyStats = {
    'Calories': 2600,
    'Protein': 180,
    'Carbs': 260,
    'Fat': 80,
  };

  // Workout Goals
  final List<Map<String, dynamic>> workoutGoals = [
    {'title': 'Push-ups', 'reps': '50 reps', 'icon': Icons.fitness_center},
    {'title': 'Running', 'reps': '5 km', 'icon': Icons.directions_run},
    {'title': 'Jump Rope', 'reps': '10 min', 'icon': Icons.sports_kabaddi},
    {'title': 'Squats', 'reps': '30 reps', 'icon': Icons.accessibility_new},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildNutritionStats(),
                    _buildWorkoutSection(),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(context),
          ],
      appBar: AppBar(
        title: const Text("Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A1F44),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Card
              _buildGoalCard(),
              const SizedBox(height: 20),

              // Updated Nutrition Section
              _buildNutritionSection(),
              const SizedBox(height: 20),

              // Workouts Section
              _buildWorkoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile_image.png'),
                  radius: 25,
                ),
              ),
              const SizedBox(width: 10), // Add some space between the profile picture and text
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Spacer(), // Pushes the notification icon to the far right
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Grey background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                ),
              ),

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F44),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Today's Goal",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(height: 5),
              Text("2100 cal",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text("735 cal remaining",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),

            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Adjust width based on content
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
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildNutritionStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.25,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: dailyStats.keys.map((title) {
          int value = showWeekly ? dailyStats[title]! * 7 : dailyStats[title]!;
          return _buildNutritionCard(
            title,
            value.toString(),
            _getUnitForTitle(title),
            _getBgColor(title),
            _getTextColor(title),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionCard(String title, String value, String unit, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _getIconForTitle(title),
                  color: (title == 'Calories' || title == 'Fat') ? Colors.black : Colors.white,
                  size: 16,
                ),
  /// 🔹 Updated Nutrition Section (Matches Your Design)
  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nutrition",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 139, 70, 70),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: const Color.fromARGB(255, 105, 105, 105),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Workout",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: workoutGoals.map((workout) {
              return _buildWorkoutCard(workout['title'], workout['reps'], workout['icon']);
            }).toList(),
          ),
        ],
      ),
              _buildNutritionItem("Calories", "2,600 cal"),
              const Divider(height: 24, thickness: 1, color: Colors.grey),
              _buildNutritionItem("Carbs", "200 g"),
              const Divider(height: 24, thickness: 1, color: Colors.grey),
              _buildNutritionItem("Protein", "180 g"),
              const Divider(height: 24, thickness: 1, color: Colors.grey),
              _buildNutritionItem("Fat", "80 g"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Workouts Section (Unchanged)
  Widget _buildWorkoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Workouts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildWorkoutItem("Morning Run", "30 min • 320 cal"),
        _buildWorkoutItem("Weight Training", "45 min • 280 cal"),
      ],
    );
  }

  Widget _buildWorkoutCard(String title, String reps, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(reps, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
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
        return Colors.grey.shade200; // Calories color
      case 'Protein':
        return Colors.black; // Protein color
      case 'Carbs':
        return Colors.blue; // Carbs color
      case 'Fat':
        return const Color.fromARGB(159, 111, 178, 255); // Fat color
      default:
        return Colors.blue.shade100; // Default background color
    }
  }

  Color _getTextColor(String title) {
    // Adjust text color for contrast
    return title == 'Protein' || title == 'Carbs' ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0);
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, true, () {}),
          _buildNavBarItem(Icons.list, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NutritionScreen()),
            );
          }),
          _buildNavBarItem(Icons.fitness_center, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkoutScreen()),
            );
          }),
          _buildNavBarItem(Icons.person, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),
        ],
      ),
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // Consider managing this dynamically
      selectedItemColor: const Color(0xFF0A1F44),
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.restaurant), label: "Nutrition"),
        BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), label: "Workout"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
            break;
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NutritionScreen()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => WorkoutScreen()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen()));
            break;
        }
      },
    );
  }

  Widget _buildNavBarItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}