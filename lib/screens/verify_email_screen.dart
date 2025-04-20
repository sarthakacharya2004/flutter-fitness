import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitness_hub/screens/login_screen.dart';
import 'package:fitness_hub/screens/signup_steps_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = true;
  bool _emailVerified = false;
  late Timer _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();

    _auth.authStateChanges().listen((User? user) {
      if (user?.emailVerified == true) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _checkEmailVerification();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _goToLogin();
        return;
      }

      await user.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified && !_emailVerified) {
        setState(() {
          _emailVerified = true;
          _isLoading = false;
        });
        _navigateToNextScreen();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToNextScreen() {
    _timer.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignupStepsScreen()),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() => _isLoading = true);
      User? user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showSnackBar("Verification email sent again!");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_outlined, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 30),
              const Text(
                "Check Your Email",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "A verification link was sent to\n${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              const Text(
                "Click the link to verify your email and continue.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resendVerificationEmail,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Resend Email"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text("Back to Login"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
