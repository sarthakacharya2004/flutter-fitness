import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';
import '../services/local_storage_service.dart';

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
  String profileImageUrl = ''; // Profile image URL from database
  bool isLoading = true;

  final NotificationService _notificationService = NotificationService();
  final ImagePicker _picker = ImagePicker();

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
    
    // Load profile image from local storage first
    try {
      String? savedImage = await LocalStorageService.getProfileImage();
      if (savedImage != null) {
        setState(() {
          profileImageUrl = savedImage;
        });
      }
    } catch (e) {
      print('Error loading profile image from local storage: $e');
    }

    User? user = FirebaseAuth.instance.currentUser; // Get current logged-in user
    if (user != null) {
      try {
        // Fetch the user profile from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            name = userData['name'] ?? ''; // Fetch name from Firestore
            description = userData['description'] ?? ''; // Fetch description
            weight = userData['weight']?.toString() ?? ''; // Fetch weight from Firestore
            height = userData['height']?.toString() ?? ''; // Fetch height from Firestore
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
                        double bmiVal = weightVal / ((heightVal / 100) * (heightVal / 100));
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
                        double bmiVal = weightVal / ((heightVal / 100) * (heightVal / 100));
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Convert weight, height, and bmi to numeric values for Firestore
        double? weightNum = double.tryParse(weight);
        double? heightNum = double.tryParse(height);
        double? bmiNum = double.tryParse(bmi);

        // Create a map of the data to update
        Map<String, dynamic> updateData = {
          'name': name,
          'description': description,
          'goal': goal,
        };

        // Only add numeric values if they are valid
        if (weightNum != null) updateData['weight'] = weightNum;
        if (heightNum != null) updateData['height'] = heightNum;
        if (bmiNum != null) updateData['bmi'] = bmiNum;

        // Update Firestore document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: ${e.toString()}')),
          );
        }
        print('Error updating profile: $e');
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
                onTap: () async {
                  final oldGoal = goal;
                  setState(() {
                    goal = 'Maintain';
                  });
                  await _saveProfile();
                  // Create notification for goal change
                  await _notificationService.createNotification(
                    'Profile',
                    customTitle: 'Goal Updated',
                    customMessage: 'Your fitness goal has been changed from $oldGoal to Maintain',
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Gain Muscles'),
                onTap: () async {
                  final oldGoal = goal;
                  setState(() {
                    goal = 'Gain Muscles';
                  });
                  await _saveProfile();
                  // Create notification for goal change
                  await _notificationService.createNotification(
                    'Profile',
                    customTitle: 'Goal Updated',
                    customMessage: 'Your fitness goal has been changed from $oldGoal to Gain Muscles',
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Lose Weight'),
                onTap: () async {
                  final oldGoal = goal;
                  setState(() {
                    goal = 'Lose Weight';
                  });
                  await _saveProfile();
                  // Create notification for goal change
                  await _notificationService.createNotification(
                    'Profile',
                    customTitle: 'Goal Updated',
                    customMessage: 'Your fitness goal has been changed from $oldGoal to Lose Weight',
                  );
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
    TextEditingController descriptionController = TextEditingController(text: description);

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
                decoration: const InputDecoration(hintText: 'Enter new description'),
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
                  Expanded(child: _buildProfileContent()), // This prevents overflow
                  _buildBottomNavBar(context),
                ],
              ),
      ),
    );
  }

  // Top bar widget (Logout and Settings Icon)
  Widget _buildTopBar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

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
          Row(
            children: [
              if (!isGoogleUser) // Only show lock icon for non-Google users
                IconButton(
                  icon: const Icon(Icons.lock),
                  onPressed: _showChangePasswordDialog,
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _navigateToScreen(context, const SettingsPage());
                },
              ),
            ],
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
                // We don't clear the profile image from local storage during logout
                // This ensures it persists for the next login
                await FirebaseAuth.instance.signOut();
                // Navigate to login screen or welcome page
                Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    // Validate inputs
                    if (oldPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New passwords do not match')),
                      );
                      return;
                    }

                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password must be at least 6 characters')),
                      );
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      // Get current user
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        throw Exception('No user logged in');
                      }

                      // Get credentials for reauthentication
                      final credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: oldPasswordController.text,
                      );

                      // Reauthenticate user
                      await user.reauthenticateWithCredential(credential);

                      // Change password
                      await user.updatePassword(newPasswordController.text);

                      // Create notification for password change
                      _notificationService.createActivityNotification(
                        'Profile',
                        'changed password',
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password changed successfully')),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      String message = 'Failed to change password';
                      if (e.code == 'wrong-password') {
                        message = 'Current password is incorrect';
                      } else if (e.code == 'weak-password') {
                        message = 'New password is too weak';
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change Password'),
                ),
              ],
            );
          },
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
      'Maintain': 'Focus on maintaining current weight while improving overall fitness and health.',
      'Gain Muscles': 'Prioritize gaining weight and muscle mass through proper nutrition and training.',
      'Lose Weight': 'Focus on reducing body weight through balanced diet and regular exercise.',
    };

    // Get description for current goal
    String description = goalDescriptions[goal] ?? 'Customize your fitness journey based on your personal goals.';

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
  // Function to handle profile image selection and local storage
  Future<void> _changeProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Limit image width
      maxHeight: 800, // Limit image height
      imageQuality: 70, // Compress image quality to 70%
    );
    if (image != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        // Save image to local storage only
        await LocalStorageService.saveProfileImage(base64Image);
        
        // Update state with base64 image
        setState(() {
          profileImageUrl = base64Image;
        });

        // Create notification for profile image update
        _notificationService.createActivityNotification(
          'Profile',
          'updated profile picture',
        );

        // Update profile in Firestore without the image
        await _saveProfile();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile image')),
          );
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _changeProfileImage,
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? MemoryImage(base64Decode(profileImageUrl))
                      : const AssetImage('assets/profile_image.png') as ImageProvider,
                  radius: 40,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Loading...', // Display the name fetched from Firestore
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
          _buildStatCard('Weight', '$weight kg', Colors.grey.shade200, Colors.black, 'weight', Icons.accessibility),
          _buildStatCard('Height', '$height cm', Colors.black, Colors.white, 'height', Icons.height),
          _buildStatCard('BMI', bmi, Colors.blue, Colors.white, 'bmi', Icons.monitor_weight),
          _buildStatCard('Goal', goal, Colors.blue.shade100, Colors.black, 'goal', Icons.flag),
        ],
      ),
    );
  }

  // Stat card widget with an editable option
  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor, String type, IconData icon) {
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
                    color: textColor == Colors.white ? Colors.white70 : Colors.grey,
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
          _buildNavBarItem(Icons.restaurant_menu, false, () {
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

  Future<void> _updateProfileField(String field, String value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({field: value});

      // Create notification for profile update
      await _notificationService.createNotification(
        'Profile',
        customTitle: 'Profile Updated',
        customMessage: 'Your $field has been updated to $value',
      );

      setState(() {
        switch (field) {
          case 'weight':
            weight = value;
            break;
          case 'height':
            height = value;
            break;
          case 'goal':
            goal = value;
            break;
          case 'name':
            name = value;
            break;
          case 'description':
            description = value;
            break;
        }
      });
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  Future<void> _updateProfileImage(XFile image) async {
    setState(() {
      isLoading = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Save image to local storage only
      await LocalStorageService.saveProfileImage(base64Image);
      
      // Update state with base64 image
      setState(() {
        profileImageUrl = base64Image;
      });

      // Create notification for profile image update
      await _notificationService.createNotification(
        'Profile',
        customTitle: 'Profile Picture Updated',
        customMessage: 'Your profile picture has been updated successfully',
      );

      // Update profile in Firestore without the image
      await _saveProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile image')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}