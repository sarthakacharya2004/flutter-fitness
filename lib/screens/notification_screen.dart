import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: const Center(
        child: Text(
          "No new notifications",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}