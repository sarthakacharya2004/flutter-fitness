import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool _notificationsEnabled = true;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadNotificationPreference();
  }

  // Load dark mode preference from SharedPreferences
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      print("Loaded dark mode preference: $isDarkMode"); // Debugging line
    });
  }

  // Save dark mode preference to SharedPreferences
  _savePreferences(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value); // Save the dark mode setting
    print("Saved dark mode preference: $value"); // Debugging line
  }

  Future<void> _loadNotificationPreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            _notificationsEnabled = doc.data()?['notificationsEnabled'] ?? true;
          });
        }
      } catch (e) {
        print('Error loading notification preference: $e');
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'notificationsEnabled': value});
        
        setState(() {
          _notificationsEnabled = value;
        });

        // Create a notification about the change
        if (value) {
          _notificationService.createActivityNotification(
            'Profile',
            'enabled notifications',
          );
        } else {
          _notificationService.createActivityNotification(
            'Profile',
            'disabled notifications',
          );
        }
      } catch (e) {
        print('Error updating notification preference: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update notification settings')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Notifications'),
            subtitle: Text(_notificationsEnabled ? 'Enabled' : 'Disabled'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About App'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Load preferences when MyApp is initialized
  }

  // Load dark mode preference from SharedPreferences
  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false; // Load dark mode setting
      print("Loaded dark mode preference in MyApp: $isDarkMode"); // Debugging line
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Use dark or light theme based on preference
      home: const SettingsPage(),
    );
  }
}
