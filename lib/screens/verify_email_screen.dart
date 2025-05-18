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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  bool _emailVerified = false;
  late Timer _timer;

 @override
void initState() {
  super.initState();

  // Start periodic email verification check
  _startEmailVerificationCheck();

  // Listen for auth state changes and navigate if verified
  _auth.authStateChanges().listen((User? user) {
    if (mounted && user != null && user.emailVerified) {
      _navigateToNextScreen();
    }
  });
}

@override
void dispose() {
  if (_timer.isActive) {
    _timer.cancel();
  }
  super.dispose();
}


  void _startEmailVerificationCheck() {
    _checkEmailVerification();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user?.emailVerified == true && !_emailVerified) {
        setState(() {
          _emailVerified = true;
          _isLoading = false;
        });
        _navigateToNextScreen();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showMessage("Verification email resent!");
      }
    } catch (e) {
      _showMessage("Failed to resend email: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToNextScreen() {
    _timer.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignupStepsScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                    Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
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
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              const Text("Haven't received the email?", style: TextStyle(fontSize: 14)),
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
}
