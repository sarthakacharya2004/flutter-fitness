import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Workout':
        return Colors.blue;
      case 'Water':
        return Colors.cyan;
      case 'Meals':
        return Colors.orange;
      case 'Profile':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Workout':
        return Icons.fitness_center;
      case 'Water':
        return Icons.water_drop;
      case 'Meals':
        return Icons.restaurant;
      case 'Profile':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification['type']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: _getNotificationColor(notification['type']),
          ),
        ),
        title: Text(
          notification['title'] ?? notification['type'] ?? 'Notification',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification['message'] ?? ''),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: notification['unread'] == true
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification['type']),
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () async {
          final docId = snapshot.data!.docs[index].id;
          await _notificationService.markAsRead(docId);
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      dateTime = DateTime.parse(timestamp.toString());
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Read All'),
          ),
          TextButton(
            onPressed: () async {
              // Show confirmation dialog
              final shouldClear = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Notifications'),
                  content: const Text('Are you sure you want to delete all notifications?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );

              if (shouldClear == true) {
                await _notificationService.clearAllMessages();
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return FutureBuilder<bool>(
              future: _notificationService.areNotificationsEnabled(),
              builder: (context, enabledSnapshot) {
                if (enabledSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notificationsEnabled = enabledSnapshot.data ?? true;

                if (!notificationsEnabled) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Notifications are turned off',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enable notifications in settings to receive updates',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                          child: const Text('Go to Settings'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('No notifications yet'),
                );
              },
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              return _buildNotificationCard(notification, snapshot, index);
            },
          );
        },
      ),
    );
  }
}
