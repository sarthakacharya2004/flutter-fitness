import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String weight = '75';
  String height = '180';
  String bmi = '23.1';
  String goal = 'Build Muscle';
  String name = 'Puskar Chamiya';
  String description = 'Fitness Enthusiast';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      weight = prefs.getString('weight') ?? weight;
      height = prefs.getString('height') ?? height;
      bmi = prefs.getString('bmi') ?? bmi;
      goal = prefs.getString('goal') ?? goal;
      name = prefs.getString('name') ?? name;
      description = prefs.getString('description') ?? description;
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight', weight);
    await prefs.setString('height', height);
    await prefs.setString('bmi', bmi);
    await prefs.setString('goal', goal);
    await prefs.setString('name', name);
    await prefs.setString('description', description);
  }

  void _showEditDialog(String type) {
    TextEditingController controller = TextEditingController(
      text: type == 'weight'
          ? weight
          : type == 'height'
              ? height
              : bmi,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _savePreferences();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog() {
    final goals = ['Lean', 'Shredded', 'Bulk', 'Muscular'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals
              .map((g) => ListTile(
                    title: Text(g),
                    onTap: () {
                      setState(() => goal = g);
                      _savePreferences();
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController descController =
        TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              controller: descController,
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
                description = descController.text;
              });
              _savePreferences();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
                onSettingsTap: () => _navigateToScreen(const SettingsPage())),
            Expanded(child: _buildProfileContent()),
            _BottomNavBar(
              currentIndex: 3,
              onTap: (index) {
                if (index == 0) _navigateToScreen(const HomeScreen());
                if (index == 1) _navigateToScreen(const NutritionScreen());
                if (index == 2) _navigateToScreen(const WorkoutScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _ProfileHeader(
            name: name,
            description: description,
            onEdit: _showEditProfileDialog,
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                title: 'Weight',
                value: '$weight kg',
                icon: Icons.accessibility,
                bgColor: Colors.grey.shade200,
                textColor: Colors.black,
                onTap: () => _showEditDialog('weight'),
              ),
              _StatCard(
                title: 'Height',
                value: '$height cm',
                icon: Icons.height,
                bgColor: Colors.black,
                textColor: Colors.white,
                onTap: () => _showEditDialog('height'),
              ),
              _StatCard(
                title: 'BMI',
                value: bmi,
                icon: Icons.monitor_weight,
                bgColor: Colors.blue,
                textColor: Colors.white,
                onTap: () => _showEditDialog('bmi'),
              ),
              _StatCard(
                title: 'Goal',
                value: goal,
                icon: Icons.flag,
                bgColor: Colors.blue.shade100,
                textColor: Colors.black,
                onTap: _showGoalDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Top Bar Widget
class _TopBar extends StatelessWidget {
  final VoidCallback onSettingsTap;
  const _TopBar({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          IconButton(
              icon: const Icon(Icons.settings), onPressed: onSettingsTap),
        ],
      ),
    );
  }
}

// Profile Header Widget
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.name,
    required this.description,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage('assets/profile_image.png'),
          radius: 40,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                ],
              ),
              Text(
                description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(
                        color: textColor.withOpacity(0.7), fontSize: 14)),
                Icon(icon, color: textColor.withOpacity(0.7)),
              ],
            ),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Bottom Navigation Bar Widget
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 0),
          _navItem(Icons.list, 1),
          _navItem(Icons.fitness_center, 2),
          _navItem(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.grey),
      ),
    );
  }
}
