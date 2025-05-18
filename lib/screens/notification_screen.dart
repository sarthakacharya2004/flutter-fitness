import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final List<String> notifications = const [
    "Your order has been shipped!",
    "New message from John",
    "Update available for your app",
    "Reminder: Meeting at 3 PM",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No new notifications",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(notifications[index]),
                    onTap: () {
                      // You could navigate or show a dialog here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped: ${notifications[index]}')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
