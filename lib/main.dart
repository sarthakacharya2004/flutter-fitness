import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart'; // Import your Login screen
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx",
        authDomain: "your-app.firebaseapp.com",
        projectId: "your-app",
        storageBucket: "your-app.appspot.com",
        messagingSenderId: "your-sender-id",
        appId: "your-app-id"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitnessHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/welcome', // Start at the welcome screen
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/nutrition': (context) => const NutritionScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
