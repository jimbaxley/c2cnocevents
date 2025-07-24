import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:c2c_noc_events/services/fcm_service.dart';

class FCMDebugScreen extends StatefulWidget {
  const FCMDebugScreen({super.key});

  @override
  State<FCMDebugScreen> createState() => _FCMDebugScreenState();
}

class _FCMDebugScreenState extends State<FCMDebugScreen> {
  String? _fcmToken;
  bool _isLoading = true;
  final List<String> _notificationLog = [];
  NotificationSettings? _notificationSettings;

  @override
  void initState() {
    super.initState();
    _loadFCMInfo();
    _setupNotificationListeners();
  }

  Future<void> _loadFCMInfo() async {
    setState(() => _isLoading = true);

    try {
      final token = await FCMService.getToken();
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      setState(() {
        _fcmToken = token;
        _notificationSettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fcmToken = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _setupNotificationListeners() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _notificationLog.insert(
            0, '🔔 Foreground: ${message.notification?.title ?? "No title"} - ${DateTime.now().toString()}');
      });
    });

    // Listen for background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        _notificationLog.insert(
            0, '👆 Tapped: ${message.notification?.title ?? "No title"} - ${DateTime.now().toString()}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Debug'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FCM Token Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FCM Token',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_fcmToken != null) ...[
                      SelectableText(
                        _fcmToken!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadFCMInfo,
                        child: const Text('Refresh Token'),
                      ),
                    ] else
                      const Text('No token available'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notification Permissions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Permissions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_notificationSettings != null) ...[
                      Text('Status: ${_notificationSettings!.authorizationStatus.name}'),
                      Text('Alert: ${_notificationSettings!.alert.name}'),
                      Text('Sound: ${_notificationSettings!.sound.name}'),
                      Text('Badge: ${_notificationSettings!.badge.name}'),
                    ] else
                      const Text('Loading permissions...'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Topic Subscription Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic Subscriptions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Auto-subscribed to: events'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await FCMService.subscribeToTopic('events');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Subscribed to events topic')),
                            );
                          },
                          child: const Text('Re-subscribe'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await FCMService.unsubscribeFromTopic('events');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Unsubscribed from events topic')),
                            );
                          },
                          child: const Text('Unsubscribe'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Testing Instructions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Copy your FCM token above\n'
                      '2. Go to Firebase Console > Messaging\n'
                      '3. Send test message to "events" topic\n'
                      '4. Or send to specific token for targeted testing\n'
                      '5. Check activity log below for delivery status',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notification Activity Log
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Notification Activity Log',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _notificationLog.clear();
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300, // Fixed height for the log
                      child: _notificationLog.isEmpty
                          ? const Center(
                              child: Text(
                                'No notifications received yet.\nSend a test message to see activity here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _notificationLog.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    _notificationLog[index],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                );
                              },
                            ),
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
