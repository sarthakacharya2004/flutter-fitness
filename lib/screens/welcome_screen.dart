import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1F44), // Dark blue background
      body: SafeArea(
        child: SingleChildScrollView( // Fix for overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50), // Extra spacing for better layout

              // App Logo
              Image.asset(
                "assets/mainlogo.png",
                width: 150,
                height: 150,
              ),

              // App Title with Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.fitness_center, size: 40, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "FitnessHub",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.fitness_center, size: 40, color: Colors.white),
                ],
              ),

              const SizedBox(height: 65),

              // Welcome Text
              const Text(
                "Welcome",
                style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 50),

              // Sign In Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("SIGN IN", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),

              const SizedBox(height: 15),

              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("SIGN UP", style: TextStyle(color: Colors.blue, fontSize: 18)),
              ),

              const SizedBox(height: 55),

              // "Continue with" Text
              const Text(
                "Continue with",
                style: TextStyle(color: Color.fromARGB(179, 255, 255, 255), fontSize: 14),
              ),

              const SizedBox(height: 20),

              // Social Media Buttons (Facebook, Google, Apple)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(asset: "assets/facebook.png"),
                  const SizedBox(width: 20),
                  SocialButton(asset: "assets/google.png", isGoogle: true),
                  const SizedBox(width: 20),
                  SocialButton(asset: "assets/apple.png"),
                ],
              ),

              const SizedBox(height: 50), // Extra space to prevent overflow issues
            ],
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String asset;
  final bool isGoogle;

  const SocialButton({super.key, required this.asset, this.isGoogle = false});

  Future<void> _handleSocialLogin(BuildContext context) async {
    try {
      if (isGoogle) { // Check if it's the Google button
        await _signInWithGoogle();
        // Navigate to HomeScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw "Google Sign-In canceled";

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleSocialLogin(context),
      child: Container(
        width: 50,
        height: 50,
        decoration: isGoogle
            ? null
            : const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
        child: ClipOval(
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}