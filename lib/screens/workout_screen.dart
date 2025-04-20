import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Strength', 'icon': Icons.fitness_center, 'colors': [Colors.red, Colors.orange]},
    {'name': 'Cardio', 'icon': Icons.directions_run, 'colors': [Colors.blue, Colors.cyan]},
    {'name': 'Yoga', 'icon': Icons.self_improvement, 'colors': [Colors.green, Colors.lightGreen]},
    {'name': 'HIIT', 'icon': Icons.flash_on, 'colors': [Colors.purple, Colors.deepPurpleAccent]},
  ];

  final List<Map<String, dynamic>> _featured = [
    {'title': 'Morning Burn', 'image': 'assets/full-body.png', 'duration': '30 mins'},
    {'title': 'Core Blaster', 'image': 'assets/core-workout.png', 'duration': '25 mins'},
    {'title': 'Quick HIIT', 'image': 'assets/hiit-workout.png', 'duration': '20 mins'},
  ];

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryGrid(),
                    const SizedBox(height: 24),
                    Text("Featured Workouts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildFeaturedList(),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back 👋', style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text('Let’s Work Out!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/profile.jpg'), // replace with your image
          )
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      itemCount: _categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 120,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final cat = _categories[index];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: cat['colors']),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: cat['colors'][1].withOpacity(0.3), blurRadius: 8)],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'], size: 36, color: Colors.white),
                const SizedBox(height: 10),
                Text(cat['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedList() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = _featured[index];
          return Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.asset(item['image'], height: 100, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(item['duration'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            _navigateToScreen(const HomeScreen());
            break;
          case 1:
            _navigateToScreen(const NutritionScreen());
            break;
          case 2:
            break;
          case 3:
            _navigateToScreen(const ProfileScreen());
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Nutrition'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
