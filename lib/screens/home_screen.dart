import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'profile_screen.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'notification_screen.dart';
import 'package:fitness_hub/services/firestore_service.dart';
import 'package:fitness_hub/services/waterintake_service.dart';

class HomeScreen extends StatefulWidget {
  final double? initialWeight;
  final String? userGoal;
  final double? weightGoal;

  const HomeScreen(
      {super.key, this.initialWeight, this.userGoal, this.weightGoal});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showWeekly = false;
  final FirestoreService _firestoreService = FirestoreService();
  String userName = '';

  // Dummy Weight Data
  final List<FlSpot> weightData = [
    FlSpot(0, 82.5),
    FlSpot(1, 82.2),
    FlSpot(2, 81.7),
    FlSpot(3, 81.8),
    FlSpot(4, 81.4),
    FlSpot(5, 81.0),
    FlSpot(6, 80.7),
  ];

  // Dummy Nutrition Stats
  final Map<String, int> dailyStats = {
    'Calories': 2600,
    'Protein': 180,
    'Carbs': 260,
    'Fat': 80,
  };

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadWaterData();

    // Save initial weight from signup if provided
    if (widget.initialWeight != null) {
      _firestoreService.addWeightLog({'weight': widget.initialWeight});
    }
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          userName = doc['name'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildWeightTracker(FirebaseAuth.instance.currentUser!.uid),
                    _buildWaterTracker(),
                    _buildNutritionStats(),
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

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile_image.png'),
                  radius: 25,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    userName.isNotEmpty ? userName : '...',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                ),
              ),
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

  Widget _buildWeightTracker(String userId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight Tracker',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final weightGoal =
                            snapshot.data?.get('weightGoal')?.toString() ??
                                'Not set';
                        return Text(
                          'Goal: $weightGoal kg',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stream to get current weight and start weight
            FutureBuilder<Map<String, double?>>(
              future: _firestoreService
                  .getStartAndCurrentWeight(), // Fetch start and current weight together
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Text(
                    'No weight logs available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }

                final startWeight = snapshot.data?['start'];
                final currentWeight = snapshot.data?['current'];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeightInfoCard(
                        'Current',
                        currentWeight != null
                            ? '$currentWeight kg'
                            : 'Not available',
                        Colors.blue),
                    _buildWeightInfoCard(
                        'Start',
                        startWeight != null ? '$startWeight kg' : 'Not set',
                        Colors.grey),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final weightGoal =
                            snapshot.data?.get('weightGoal')?.toString() ??
                                'Not set';
                        return _buildWeightInfoCard(
                            'Goal', '$weightGoal kg', Colors.green);
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showWeightUpdateDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update Weight'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfoCard(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showWeightUpdateDialog(BuildContext context) {
    double newWeight = 80.7; // Default value

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) newWeight = parsed;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newWeight <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid weight")),
                );
                return;
              }

              try {
                await _firestoreService.addWeightLog({'weight': newWeight});
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error saving weight: $e")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  WaterIntakeService waterService = WaterIntakeService();

  double waterIntake = 0.0;
  double waterGoal = 2.0; // Liters
  List<double> waterHistory = List.filled(7, 0.0);

  Future<void> _loadWaterData() async {
    double todayIntake = await waterService.getTodayWaterIntake();
    List<double> history = await waterService.getLast7DaysIntake(waterGoal);
    setState(() {
      waterIntake = todayIntake;
      waterHistory = history;
    });
  }

  Future<void> _updateWaterIntake(double amount) async {
    if (!mounted) return;
    try {
      double newIntake = (waterIntake + amount).clamp(0.0, waterGoal);
      await waterService.saveWaterIntake(newIntake);
      if (!mounted) return;

      // Update only water-related state
      setState(() {
        waterIntake = newIntake;
      });

      // Fetch history in background without showing errors
      try {
        final history = await waterService.getLast7DaysIntake(waterGoal);
        if (mounted) {
          setState(() {
            waterHistory = history;
          });
        }
      } catch (historyError) {
        // Silently handle history fetch errors
      }
    } catch (e) {
      if (mounted) {
        // Only show error if the main water intake update fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating water intake: $e")),
        );
      }
    }
  }

  Widget _buildWaterTracker() {
    final double percentage = (waterIntake / waterGoal) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Water Intake',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${waterIntake.toStringAsFixed(2)} / ${waterGoal.toStringAsFixed(2)} L',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 180 * (waterIntake / waterGoal),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue[300]!,
                          Colors.blue[700]!,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: const Radius.circular(16),
                        top: Radius.circular(waterIntake >= waterGoal ? 16 : 0),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.water_drop,
                      size: 60,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${percentage.round()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCustomWaterInput(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildWaterButton('+100 ml', Icons.add, () {
                    _updateWaterIntake(0.1);
                  }, Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWaterButton('+50 ml', Icons.add, () {
                    _updateWaterIntake(0.05);
                  }, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildWaterButton('-50 ml', Icons.remove, () {
                    _updateWaterIntake(-0.05);
                  }, Colors.red),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWaterButton('Reset', Icons.refresh, () {
                    _updateWaterIntake(-waterIntake);
                  }, Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final intake = waterHistory[index];
                  final percentage = (intake / waterGoal) * 100;

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                height: percentage,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.blue[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dayLabels[index],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomWaterInput() {
    final TextEditingController _customWaterController =
        TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customWaterController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'ml',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              final input = double.tryParse(_customWaterController.text);
              if (input != null && input > 0) {
                _updateWaterIntake(input / 1000); // Convert ml to L
                _customWaterController.clear();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(8)),
              ),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(
      String text, IconData icon, VoidCallback onPressed, MaterialColor color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color[50],
          foregroundColor: color[700],
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 5),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: dailyStats.keys.map((title) {
              int value =
                  showWeekly ? dailyStats[title]! * 7 : dailyStats[title]!;
              return _buildNutritionCard(
                title,
                value.toString(),
                _getUnitForTitle(title),
                _getBgColor(title),
                _getTextColor(title),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
      String title, String value, String unit, Color bgColor, Color textColor) {
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
                  fontSize: 16,
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
                  color: (title == 'Calories' || title == 'Fat')
                      ? Colors.black
                      : Colors.white,
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
        return 'g';
      case 'Carbs':
        return 'g';
      case 'Fat':
        return 'g';
      default:
        return '';
    }
  }

  Color _getBgColor(String title) {
    switch (title) {
      case 'Calories':
        return Colors.grey.shade200;
      case 'Protein':
        return Colors.black;
      case 'Carbs':
        return Colors.blue;
      case 'Fat':
        return const Color.fromARGB(159, 111, 178, 255);
      default:
        return Colors.blue.shade100;
    }
  }

  Color _getTextColor(String title) {
    return title == 'Protein' || title == 'Carbs'
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 0, 0, 0);
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
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
