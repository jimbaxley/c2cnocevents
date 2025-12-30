import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:team_up_nc/widgets/notification_detail_modal.dart';
import 'package:team_up_nc/main.dart';
import 'package:flutter/services.dart';

// iOS notification tap method channel
const MethodChannel _notificationTapChannel = MethodChannel('team_up_nc/notification_tap');

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
    // TODO: Send token and deviceId to your backend API
    // Example:
    // await ApiService.registerFcmToken(token, deviceId);
  }

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      // Delete old token to force fresh generation
      await _messaging.deleteToken();
      print('🗑️ Deleted old FCM token');
      
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

      print('📱 Notification Permission Status: ${settings.authorizationStatus}');

      // Get FRESH FCM token
      String? token = await getToken();
      if (token != null) {
        print('🔑 NEW FCM Token: $token');
        await registerToken(token);
      } else {
        print('⚠️ FCM Token is null');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM Token refreshed: $newToken');
        await registerToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      print('✅ FCM listeners registered');

      // NOTE: Background message handler is registered in main.dart BEFORE Firebase.initializeApp()
      // This is required by Flutter for proper background message handling

      // Handle notification tap when app is terminated or in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Auto-subscribe to general topic
      await subscribeToTopic('general');
      print('📢 Subscribed to topic: general');
    } catch (e) {
      // FCM initialization failed - log for debugging
      print('❌ FCM initialization error: $e');
      rethrow; // Re-throw to see the full error
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Received foreground message: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
    final notification = NotificationItem.fromRemoteMessage(message);
    await NotificationStorage.addNotification(notification);
  }

  // Store a pending notification to be shown after the widget tree is ready
  static NotificationItem? pendingNotification;

  // Handle message when app is opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    final notification = NotificationItem.fromRemoteMessage(message);
    pendingNotification = notification;
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
    } catch (e) {
      print('❌ Failed to subscribe to topic $topic: $e');
    }
  }

  // Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {}
  }

  // Get current FCM token and print for debugging
  static Future<void> printCurrentToken() async {
    try {
      String? token = await getToken();
      if (token != null) {}
    } catch (e) {}
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 ========== BACKGROUND HANDLER CALLED ==========');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
  print('   Data: ${message.data}');
  print('   Has data: ${message.data.isNotEmpty}');
  
  // Store the notification - Firebase is already initialized
  final notification = NotificationItem.fromRemoteMessage(message);
  await NotificationStorage.addNotification(notification);
  
  print('✅ Background Handler - Notification stored');
  print('========== BACKGROUND HANDLER END ==========');
}
