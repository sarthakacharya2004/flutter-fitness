import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String weight = ''; // Weight from database
  String height = ''; // Height from database
  String bmi = ''; // BMI from database
  String goal = ''; // Goal from database
  String name = ''; // Name from database
  String description = ''; // Description from database
  bool isLoading = true;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Load user profile from Firestore when screen is initialized
  }

  // Load profile from Firestore
  _loadProfile() async {
    setState(() {
      isLoading = true;
    });

    User? user =
        FirebaseAuth.instance.currentUser; // Get current logged-in user
    if (user != null) {
      try {
        // Fetch the user profile from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            name = userData['name'] ?? ''; // Fetch name from Firestore
            description = userData['description'] ?? ''; // Fetch description
            weight = userData['weight']?.toString() ??
                ''; // Fetch weight from Firestore
            height = userData['height']?.toString() ??
                ''; // Fetch height from Firestore
            bmi = userData['bmi']?.toString() ?? ''; // Fetch BMI from Firestore
            goal = userData['goal'] ?? ''; // Fetch goal from Firestore
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show dialog to edit values (weight, height, or bmi)
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
                    String oldWeight = weight;
                    weight = controller.text;
                    // Create notification for weight update
                    double? newWeightVal = double.tryParse(weight);
                    double? oldWeightVal = double.tryParse(oldWeight);
                    if (newWeightVal != null && oldWeightVal != null) {
                      double difference = newWeightVal - oldWeightVal;
                      _notificationService.createActivityNotification(
                        'Profile',
                        'updated weight from ${oldWeight}kg to ${weight}kg',
                      );
                    }
                    // Only recalculate BMI if both weight and height are available
                    if (weight.isNotEmpty && height.isNotEmpty) {
                      double? weightVal = double.tryParse(weight);
                      double? heightVal = double.tryParse(height);
                      if (weightVal != null && heightVal != null) {
                        double bmiVal =
                            weightVal / ((heightVal / 100) * (heightVal / 100));
                        bmi = bmiVal.toStringAsFixed(1);
                      }
                    }
                  } else if (type == 'height') {
                    height = controller.text;
                    // Only recalculate BMI if both weight and height are available
                    if (weight.isNotEmpty && height.isNotEmpty) {
                      double? weightVal = double.tryParse(weight);
                      double? heightVal = double.tryParse(height);
                      if (weightVal != null && heightVal != null) {
                        double bmiVal =
                            weightVal / ((heightVal / 100) * (heightVal / 100));
                        bmi = bmiVal.toStringAsFixed(1);
                      }
                    }
                  } else if (type == 'bmi') {
                    bmi = controller.text;
                  }
                });
                _saveProfile(); // Save the updated value to Firestore
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

  // Save profile to Firestore
  _saveProfile() async {
    User? user =
        FirebaseAuth.instance.currentUser; // Get current logged-in user
    if (user != null) {
      // Update user profile in Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': name,
          'description': description,
          'weight': weight,
          'height': height,
          'bmi': bmi,
          'goal': goal,
        });
        // Show success message
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
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
                title: Text('Maintain'),
                onTap: () {
                  setState(() {
                    goal = 'Maintain';
                  });
                  _saveProfile();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Gain Muscles'),
                onTap: () {
                  setState(() {
                    goal = 'Gain Muscles';
                  });
                  _saveProfile();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Lose Weight'),
                onTap: () {
                  setState(() {
                    goal = 'Lose Weight';
                  });
                  _saveProfile();
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
                _saveProfile(); // Save the updated name and description to Firestore
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                      child: _buildProfileContent()), // This prevents overflow
                  _buildBottomNavBar(context),
                ],
              ),
      ),
    );
  }

  // Top bar widget (Logout and Settings Icon)
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logoutUser,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _navigateToScreen(context, const SettingsPage());
            },
          ),
        ],
      ),
    );
  }

  void _logoutUser() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await FirebaseAuth.instance.signOut();
                // Navigate to login screen or welcome page
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/welcome', (route) => false);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
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
          const SizedBox(height: 20),
          _buildGoalDescription(),
        ],
      ),
    );
  }

  // Goal description widget
  Widget _buildGoalDescription() {
    // Maps goals to their descriptions
    Map<String, String> goalDescriptions = {
      'Maintain':
          'Focus on maintaining current weight while improving overall fitness and health.',
      'Gain Muscles':
          'Prioritize gaining weight and muscle mass through proper nutrition and training.',
      'Lose Weight':
          'Focus on reducing body weight through balanced diet and regular exercise.',
    };

    // Get description for current goal
    String description = goalDescriptions[goal] ??
        'Customize your fitness journey based on your personal goals.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Goal Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
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
                    name.isNotEmpty
                        ? name
                        : 'Loading...', // Display the name fetched from Firestore
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showEditProfileDialog, // Show edit dialog
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
