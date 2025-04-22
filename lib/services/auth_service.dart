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
  late Timer _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
    // Listen for auth state changes (for when user returns to app after verifying)
    _auth.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
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
    // Check immediately
    _checkEmailVerification();
    
    // Then check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
      return;
    }

    try {
      // Force refresh the user's verification status
      await user.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified && !_emailVerified) {
        if (mounted) {
          setState(() {
            _emailVerified = true;
            _isLoading = false;
          });
          _navigateToNextScreen();
        }
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToNextScreen() {
    _timer.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignupStepsScreen()),
    );
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() => _isLoading = true);
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email resent!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend email: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Back",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Verify Your Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.email_outlined, size: 60, color: Colors.blue),
                    const SizedBox(height: 20),
                    Text(
                      "We've sent a verification link to ${widget.email}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please check your inbox and click the link to verify your email address.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          const Text(
                            "Haven't received the email?",
                            style: TextStyle(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: _resendVerificationEmail,
                            child: const Text("Resend Verification Email"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}asfd