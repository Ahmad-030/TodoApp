import 'package:flutter/material.dart';
import '../services/Storage Service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State {
  int _pendingNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  Future _loadPendingNotifications() async {
    final pending = await NotificationService.getPendingNotifications();
    setState(() {
      _pendingNotifications = pending.length;
    });
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your tasks and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearTodos();
              await NotificationService.cancelAllNotifications();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle('Notifications'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Pending Reminders'),
                  subtitle: Text('$_pendingNotifications scheduled'),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadPendingNotifications,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_off),
                  title: const Text('Cancel All Notifications'),
                  subtitle: const Text('Clear all pending reminders'),
                  onTap: () async {
                    await NotificationService.cancelAllNotifications();
                    _loadPendingNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications cancelled'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Test Notification'),
                  subtitle: const Text('Send a test reminder'),
                  onTap: () {
                    NotificationService.showNotification(
                      'Test Reminder',
                      'Your notifications are working perfectly! 🎉',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Data'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all tasks permanently'),
              onTap: _showClearDataDialog,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('How It Works'),
                  subtitle: const Text('Learn about reminders'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('How Reminders Work'),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '🔔 Automatic Reminders',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'You\'ll receive a notification 1 day before your task is due at 9:00 AM.',
                              ),
                              SizedBox(height: 16),
                              Text(
                                '✅ Completion',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'When you mark a task as complete, its reminder is automatically cancelled.',
                              ),
                              SizedBox(height: 16),
                              Text(
                                '🗑️ Deletion',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Swipe left on any task to delete it. This will also cancel its reminder.',
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}