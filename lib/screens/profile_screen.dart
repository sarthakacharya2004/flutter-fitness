import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart'; // Import your settings screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String weight = '75'; // Default weight
  String height = '180'; // Default height
  String bmi = '23.1'; // Default BMI
  String goal = 'Build Muscle'; // Default goal
  String name = 'Puskar Chamiya'; // Default name
  String description = 'Fitness Enthusiast'; // Default description

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load saved preferences
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      weight =
          prefs.getString('weight') ?? '75'; // Default to '75' if not found
      height =
          prefs.getString('height') ?? '180'; // Default to '180' if not found
      bmi = prefs.getString('bmi') ?? '23.1'; // Default to '23.1' if not found
      goal = prefs.getString('goal') ?? 'Build Muscle'; // Default if not found
      name =
          prefs.getString('name') ?? 'Puskar Chamiya'; // Default if not found
      description = prefs.getString('description') ??
          'Fitness Enthusiast'; // Default if not found
    });
  }

  // Save preferences
  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('weight', weight);
    prefs.setString('height', height);
    prefs.setString('bmi', bmi);
    prefs.setString('goal', goal);
    prefs.setString('name', name); // Save name
    prefs.setString('description', description); // Save description
  }

  // Show dialog to edit values (weight or height)
  void _showEditDialog(String type) {
    TextEditingController controller;
    if (type == 'weight') {
      controller = TextEditingController(text: weight);
    } else if (type == 'height') {
      controller = TextEditingController(text: height);
    } else if (type == 'bmi') {
      controller = TextEditingController(text: bmi);
    } else {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $type'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter new $type'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (type == 'weight') {
                    weight = controller.text;
                  } else if (type == 'height') {
                    height = controller.text;
                  } else if (type == 'bmi') {
                    bmi = controller.text;
                  }
                });
                _savePreferences(); // Save the updated value
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show goal selection dialog
  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Lean'),
                onTap: () {
                  setState(() {
                    goal = 'Lean';
                  });
                  _savePreferences();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Shredded'),
                onTap: () {
                  setState(() {
                    goal = 'Shredded';
                  });
                  _savePreferences();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Bulk'),
                onTap: () {
                  setState(() {
                    goal = 'Bulk';
                  });
                  _savePreferences();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Muscular'),
                onTap: () {
                  setState(() {
                    goal = 'Muscular';
                  });
                  _savePreferences();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show dialog to edit name and description
  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController descriptionController =
        TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Enter new name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(hintText: 'Enter new description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  name = nameController.text;
                  description = descriptionController.text;
                });
                _savePreferences(); // Save the updated name and description
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Navigate to different screen
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
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
            _buildTopBar(context),
            Expanded(child: _buildProfileContent()), // This prevents overflow
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  // Top bar widget (Settings Icon at the top-right corner)
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to Settings Screen
              _navigateToScreen(context, const SettingsPage());
            },
          ),
        ],
      ),
    );
  }

  // Profile content (Profile header, Statistics, etc.)
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildStatistics(),
        ],
      ),
    );
  }

  // Profile header widget
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/profile_image.png'),
            radius: 40,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditProfileDialog(); // Show edit dialog
                    },
                  ),
                ],
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Color.fromARGB(255, 105, 105, 105),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Statistics grid widget
  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildStatCard('Weight', '$weight kg', Colors.grey.shade200,
              Colors.black, 'weight', Icons.accessibility),
          _buildStatCard('Height', '$height cm', Colors.black, Colors.white,
              'height', Icons.height),
          _buildStatCard('BMI', bmi, Colors.blue, Colors.white, 'bmi',
              Icons.monitor_weight),
          _buildStatCard('Goal', goal, Colors.blue.shade100, Colors.black,
              'goal', Icons.flag),
        ],
      ),
    );
  }

  // Stat card widget with an editable option
  Widget _buildStatCard(String title, String value, Color bgColor,
      Color textColor, String type, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (type == 'goal') {
          _showGoalDialog();
        } else {
          _showEditDialog(type);
        }
      },
      child: Container(
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
                    color: textColor == Colors.white
                        ? Colors.white70
                        : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  icon,
                  color: textColor == Colors.white ? Colors.white : Colors.grey,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Bottom navigation bar widget
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
          _buildNavBarItem(Icons.fitness_center, false, () {
            _navigateToScreen(context, const WorkoutScreen());
          }),
          _buildNavBarItem(Icons.person, true, () {}),
        ],
      ),
    );
  }

  // Navigation bar item widget
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
