import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Load preferences when SettingsPage is initialized
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Settings'),
            subtitle: const Text('Update your profile details'),
            onTap: () {
              // Navigate to profile settings
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark mode for better visibility'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
                _savePreferences(isDarkMode); // Save the new preference
                print("Toggled dark mode: $isDarkMode"); // Debugging line
              });
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive workout reminders and updates'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          const ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacy Settings'),
            subtitle: Text('Manage your data and permissions'),
            onTap: null,
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
