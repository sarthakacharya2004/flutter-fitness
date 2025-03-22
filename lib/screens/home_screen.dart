import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold,  color: Colors.white)),
        backgroundColor: Color(0xFF0A1F44),
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
              // Updated Goal Card
              _buildGoalCard(),
              const SizedBox(height: 20),

              // Nutrition Section
              _buildNutritionSection(),
              const SizedBox(height: 20),

              // Workouts Section
              _buildWorkoutSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /// 🔹 Updated Goal Card (Matches Your UI Reference)
  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFF0A1F44),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Today's Goal", style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(height: 5),
              Text("2100 cal", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("735 cal remaining", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(color: Colors.purple, radius: 8),
                  PieChartSectionData(color: Colors.green, radius: 8),
                  PieChartSectionData(color: Colors.orange, radius: 8),
                ],
                sectionsSpace: 0,
                centerSpaceRadius: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Nutrition Section
  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nutrition", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutritionItem("Protein", 35, Color(0xFF0A1F44)),
                  _buildNutritionItem("Carbs", 30, Colors.green),
                  _buildNutritionItem("Fat", 35, Colors.orange),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 100,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(color: Color(0xFF0A1F44), radius: 30),
                      PieChartSectionData(color: Colors.green, radius: 30),
                      PieChartSectionData(color: Colors.orange, radius: 30),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionItem(String title, int percentage, Color color) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: color, radius: 6),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text("$percentage%", style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  /// 🔹 Workouts Section
  Widget _buildWorkoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Workouts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildWorkoutItem("Morning Run", "30 min • 320 cal"),
        _buildWorkoutItem("Weight Training", "45 min • 280 cal"),
      ],
    );
  }

  Widget _buildWorkoutItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
        ],
      ),
    );
  }

  /// 🔹 Bottom Navigation Bar with "Workout" Tab Added
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Color(0xFF0A1F44),
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Nutrition"),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workout"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      onTap: (index) {
        // Handle navigation logic
      },
    );
  }
}
