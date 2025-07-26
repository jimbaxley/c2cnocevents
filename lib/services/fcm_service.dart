import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:c2c_noc_events/widgets/notification_detail_modal.dart';
import 'package:c2c_noc_events/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

// iOS notification tap method channel
const MethodChannel _notificationTapChannel = MethodChannel('c2c_noc_events/notification_tap');

void setupiOSNotificationTapListener() {
  _notificationTapChannel.setMethodCallHandler((call) async {
    if (call.method == 'notificationTapped' && call.arguments != null) {
      final Map<dynamic, dynamic> payload = call.arguments;
      final title = payload['title'] ??
          (payload['aps'] != null && payload['aps']['alert'] != null ? payload['aps']['alert']['title'] : null) ??
          'No Title';
      final body = payload['body'] ??
          (payload['aps'] != null && payload['aps']['alert'] != null ? payload['aps']['alert']['body'] : null) ??
          'No Body';
      final notification = NotificationItem(
        id: payload['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        data: Map<String, dynamic>.from(payload),
        isRead: false,
      );
      if (navigatorKey.currentContext != null) {
        showNotificationModal(navigatorKey.currentContext!, notification);
      }
    }
    return;
  });
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

// Helper to get or generate a device identifier
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = _generateRandomId();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  static String _generateRandomId() {
    final rand = Random();
    return List.generate(16, (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

// Send token and device ID to backend
  static Future<void> registerToken(String token) async {
    final deviceId = await getDeviceId();
    print('🔄 Registering token for device: $deviceId');
    // TODO: Send token and deviceId to your backend API
    // Example:
    // await ApiService.registerFcmToken(token, deviceId);
  }

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM token
      String? token = await getToken();
      if (token != null) {
        await registerToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await registerToken(newToken);
      });

      // Handle foreground messages
      print('📱 Setting up message handlers...');
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification tap when app is terminated or in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Auto-subscribe to events topic
      await subscribeToTopic('events');
    } catch (e) {
      // FCM initialization failed - log for debugging
      print('❌ FCM initialization error: $e');
      rethrow; // Re-throw to see the full error
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Foreground FCM message received:');
    print('  Title: \\${message.notification?.title}');
    print('  Body: \\${message.notification?.body}');
    print('  Data: \\${message.data}');
    final notification = NotificationItem.fromRemoteMessage(message);
    print('📥 Creating NotificationItem:');
    print('  Title: \\${notification.title}');
    print('  Body: \\${notification.body}');
    await NotificationStorage.addNotification(notification);
    print('💾 Notification added to storage (foreground)');
  }

  // Store a pending notification to be shown after the widget tree is ready
  static NotificationItem? pendingNotification;

  // Handle message when app is opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    final notification = NotificationItem.fromRemoteMessage(message);
    pendingNotification = notification;
    print('🔔 Pending notification set for modal display.');
  }

  // Get current FCM token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      // Error getting FCM token
      return null;
    }
  }

  // Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Successfully subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Successfully unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  // Get current FCM token and print for debugging
  static Future<void> printCurrentToken() async {
    try {
      String? token = await getToken();
      if (token != null) {
        print('📱 Current FCM Token: $token');
      } else {
        print('❌ No FCM token available');
      }
    } catch (e) {
      print('❌ Error getting current token: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background FCM message received:');
  print('  Title: \\${message.notification?.title}');
  print('  Body: \\${message.notification?.body}');
  print('  Data: \\${message.data}');
  final notification = NotificationItem.fromRemoteMessage(message);
  print('📥 Creating NotificationItem (background):');
  print('  Title: \\${notification.title}');
  print('  Body: \\${notification.body}');
  await NotificationStorage.addNotification(notification);
  print('💾 Notification added to storage (background)');
}
