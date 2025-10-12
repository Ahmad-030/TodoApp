import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/Storage Service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _pendingNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  Future<void> _loadPendingNotifications() async {
    final pending = await NotificationService.getPendingNotifications();
    setState(() {
      _pendingNotifications = pending.length;
    });
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your tasks and cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clearTodos();
              await NotificationService.cancelAllNotifications();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('All data cleared successfully'),
                    ],
                  ),
                  backgroundColor: Color(0xFF2196F3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Debug & Testing'),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildListTile(
                      icon: Icons.bug_report,
                      iconColor: Colors.purple,
                      title: 'Schedule Test (2 min)',
                      subtitle: 'Creates alarm 2 minutes from now',
                      onTap: () async {
                        final now = DateTime.now();
                        final testTime = now.add(const Duration(minutes: 2));
                        final testTodo = Todo(
                          id: 'test_${now.millisecondsSinceEpoch}',
                          title: 'TEST ALARM',
                          description: 'This is a test alarm set for 2 minutes from now',
                          dueDate: testTime,
                          dueTime: TimeOfDay.fromDateTime(testTime),
                          createdAt: now,
                          notificationId: now.millisecondsSinceEpoch ~/ 1000,
                        );

                        await NotificationService.scheduleNotification(testTodo);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.alarm, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Test alarm set for ${TimeOfDay.fromDateTime(testTime).format(context)}'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.purple,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }

                        _loadPendingNotifications();
                      },
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.schedule,
                      iconColor: Colors.blue,
                      title: 'Schedule Test (30 sec)',
                      subtitle: 'Creates alarm 30 seconds from now',
                      onTap: () async {
                        final now = DateTime.now();
                        final testTime = now.add(const Duration(seconds: 30));
                        final testTodo = Todo(
                          id: 'test_${now.millisecondsSinceEpoch}',
                          title: '🚨 30 SECOND TEST',
                          description: 'Should ring in 30 seconds!',
                          dueDate: testTime,
                          dueTime: TimeOfDay.fromDateTime(testTime),
                          createdAt: now,
                          notificationId: now.millisecondsSinceEpoch ~/ 1000,
                        );

                        await NotificationService.scheduleNotification(testTodo);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.timer, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Alarm will ring in 30 seconds! Check console logs.'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.blue,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }

                        _loadPendingNotifications();
                      },
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.info_outline,
                      iconColor: Colors.orange,
                      title: 'View Debug Logs',
                      subtitle: 'Check console for scheduling info',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.info, color: Colors.orange),
                                SizedBox(width: 12),
                                Text('Debug Information'),
                              ],
                            ),
                            content: const SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Check Your Console',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'When you create or schedule an alarm, look for these messages in your console/logcat:',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 12),
                                  Text('✅ = Success', style: TextStyle(color: Colors.green)),
                                  Text('❌ = Error', style: TextStyle(color: Colors.red)),
                                  Text('⚠️ = Warning', style: TextStyle(color: Colors.orange)),
                                  Text('📋 = Pending count'),
                                  Text('⏰ = Time info'),
                                  SizedBox(height: 12),
                                  Text(
                                    'Key Messages to Look For:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text('• "Main alarm scheduled successfully"'),
                                  Text('• "VERIFIED: Main alarm is in pending list"'),
                                  Text('• Total pending notifications count'),
                                  SizedBox(height: 12),
                                  Text(
                                    'If You See Errors:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text('• Check permissions are granted'),
                                  Text('• Check battery optimization is OFF'),
                                  Text('• Try the 30-second test alarm'),
                                  Text('• Restart the app'),
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
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Notifications'),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildListTile(
                      icon: Icons.notifications_active,
                      iconColor: const Color(0xFF2196F3),
                      title: 'Pending Alarms',
                      subtitle: '$_pendingNotifications scheduled',
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadPendingNotifications,
                        tooltip: 'Refresh',
                      ),
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.notifications_off,
                      iconColor: Colors.orange,
                      title: 'Cancel All Alarms',
                      subtitle: 'Clear all pending notifications',
                      onTap: () async {
                        await NotificationService.cancelAllNotifications();
                        _loadPendingNotifications();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('All alarms cancelled'),
                                ],
                              ),
                              backgroundColor: Color(0xFF2196F3),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.alarm,
                      iconColor: Colors.green,
                      title: 'Test Alarm',
                      subtitle: 'Send a test notification',
                      onTap: () {
                        NotificationService.showNotification(
                          '⏰ Test Alarm',
                          'Your alarms are working perfectly! 🎉',
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Data Management'),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildListTile(
                      icon: Icons.delete_forever,
                      iconColor: Colors.red,
                      title: 'Clear All Data',
                      subtitle: 'Delete all tasks permanently',
                      onTap: _showClearDataDialog,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('About'),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildListTile(
                      icon: Icons.info,
                      iconColor: const Color(0xFF2196F3),
                      title: 'App Version',
                      subtitle: '1.0.0',
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      icon: Icons.help,
                      iconColor: Colors.purple,
                      title: 'How It Works',
                      subtitle: 'Learn about alarms & reminders',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.help,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('How It Works'),
                              ],
                            ),
                            content: const SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '⏰ Alarm-Style Notifications',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'You\'ll receive an alarm notification at the exact time your task is due. The alarm will vibrate, play a sound, and show as a high-priority notification.',
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '🔔 Early Reminder',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'You\'ll also get a gentle reminder 1 hour before the task is due, so you have time to prepare.',
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '✅ Completion',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'When you mark a task as complete, all its alarms are automatically cancelled.',
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '🗑️ Deletion',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Swipe left on any task to delete it. This will also cancel all its alarms.',
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '📱 Permissions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Make sure to allow notification permissions and exact alarm permissions for the best experience.',
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
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}