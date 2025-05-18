import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<String> notifications = [
    "Your order has been shipped!",
    "New message from John",
    "Update available for your app",
    "Reminder: Meeting at 3 PM",
  ];

  String getCurrentTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  void clearNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: clearNotifications,
              tooltip: "Clear All",
            ),
        ],
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "You're all caught up!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.deepPurple),
                    title: Text(notifications[index]),
                    subtitle: Text("Received at ${getCurrentTime()}"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You opened: ${notifications[index]}')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
