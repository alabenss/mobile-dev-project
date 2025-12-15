import 'package:flutter/material.dart';
import '../../../services/notification_service.dart';
import '../../../database/repo/habit_repo.dart';
import '../../../models/habit_model.dart';

class TestNotificationsScreen extends StatefulWidget {
  const TestNotificationsScreen({super.key});

  @override
  State<TestNotificationsScreen> createState() => _TestNotificationsScreenState();
}

class _TestNotificationsScreenState extends State<TestNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final HabitRepository _habitRepo = HabitRepository();
  List<dynamic> _pendingNotifications = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  Future<void> _loadPendingNotifications() async {
    setState(() => _loading = true);
    try {
      final pending = await _notificationService.getPendingNotifications();
      setState(() {
        _pendingNotifications = pending;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to load notifications: $e');
    }
  }

  Future<void> _testImmediateNotification() async {
    try {
      await _notificationService.showImmediateNotification(
        'Test Notification',
        'This is a test notification! 🎯',
        payload: 'test_habit',
      );
      _showSuccess('Test notification sent!');
    } catch (e) {
      _showError('Failed to send notification: $e');
    }
  }

  Future<void> _scheduleTestHabit() async {
    try {
      // Create a test habit for 1 minute from now
      final now = DateTime.now();
      final testTime = now.add(const Duration(minutes: 1));
      
      final testHabit = Habit(
        title: 'Test Habit',
        habitKey: 'test_habit_${now.millisecondsSinceEpoch}',
        icon: Icons.star,
        frequency: 'Daily',
        time: TimeOfDay(hour: testTime.hour, minute: testTime.minute),
        reminder: true,
        points: 10,
      );

      await _habitRepo.insertHabit(testHabit);
      _showSuccess('Test habit scheduled for ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}');
      await _loadPendingNotifications();
    } catch (e) {
      _showError('Failed to schedule test habit: $e');
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    try {
      await _habitRepo.rescheduleAllNotifications();
      _showSuccess('All notifications rescheduled!');
      await _loadPendingNotifications();
    } catch (e) {
      _showError('Failed to reschedule: $e');
    }
  }

  Future<void> _cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      _showSuccess('All notifications cancelled!');
      await _loadPendingNotifications();
    } catch (e) {
      _showError('Failed to cancel notifications: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFFFF9C4), Color(0xFFFFE0B2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Test Controls Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Notification Controls',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: _testImmediateNotification,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Send Test Notification Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ElevatedButton.icon(
                      onPressed: _scheduleTestHabit,
                      icon: const Icon(Icons.schedule),
                      label: const Text('Schedule Test Habit (1 min)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ElevatedButton.icon(
                      onPressed: _rescheduleAllNotifications,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reschedule All Notifications'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ElevatedButton.icon(
                      onPressed: _cancelAllNotifications,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel All Notifications'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ElevatedButton.icon(
                      onPressed: _loadPendingNotifications,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pending Notifications Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pending Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_pendingNotifications.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_pendingNotifications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.notifications_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No pending notifications',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pendingNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = _pendingNotifications[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.notifications, color: Colors.white),
                            ),
                            title: Text(
                              notification.title ?? 'No title',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              notification.body ?? 'No body',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              'ID: ${notification.id}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How to Test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Tap "Send Test Notification Now" to see an immediate notification\n\n'
                      '2. Tap "Schedule Test Habit (1 min)" to schedule a notification for 1 minute from now\n\n'
                      '3. Wait 1 minute to receive the scheduled notification\n\n'
                      '4. Check "Pending Notifications" to see what\'s scheduled\n\n'
                      '5. Use "Reschedule All" to reload all habit reminders',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}