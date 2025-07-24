import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize FCM
  static Future<void> initialize() async {
    print('🔄 Starting FCM initialization...');
    try {
      // Request permission for notifications
      print('📱 Requesting notification permissions...');
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 Permission status: ${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('✅ User granted provisional permission');
      } else {
        print('❌ User declined or has not accepted permission');
      }

      // Initialize local notifications
      print('🔔 Initializing local notifications...');
      await _initializeLocalNotifications();
      print('✅ Local notifications initialized');

      // Get FCM token
      print('🔑 Getting FCM token...');
      String? token = await getToken();
      if (token != null && token.isNotEmpty) {
        print('✅ FCM token obtained: ${token.substring(0, 20)}...');
        // TODO: Send this token to your server to store for targeted messaging
      } else {
        print('❌ Failed to get FCM token');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM token refreshed');
        // TODO: Send updated token to your server
      });

      // Handle foreground messages
      print('📱 Setting up message handlers...');
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification tap when app is terminated or in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Auto-subscribe to events topic
      print('📝 Subscribing to events topic...');
      await subscribeToTopic('events');

      print('✅ FCM Service initialized successfully');
    } catch (e) {
      // FCM initialization failed - log for debugging
      print('❌ FCM initialization error: $e');
      rethrow; // Re-throw to see the full error
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    print('🔔 Setting up Android notification settings...');
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    print('🍎 Setting up iOS notification settings...');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    print('🔔 Initializing local notifications plugin...');
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    print('📱 Creating Android notification channel...');
    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'c2c_events_channel',
      'C2C Events Notifications',
      description: 'Notifications for C2C+NoC Events',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    print('✅ Local notifications setup complete');
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Received foreground message: ${message.messageId}');
    print('📱 Title: ${message.notification?.title}');
    print('📱 Body: ${message.notification?.body}');
    
    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to specific screen based on notification data
  }

  // Handle message when app is opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    // TODO: Navigate to specific screen based on message data
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    print('🔔 Attempting to show local notification...');
    final String title = message.notification?.title ?? 'C2C+NoC Events';
    final String body = message.notification?.body ?? 'New notification';
    print('🔔 Title: $title, Body: $body');

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'c2c_events_channel',
      'C2C Events Notifications',
      channelDescription: 'Notifications for C2C+NoC Events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
      print('✅ Local notification shown successfully');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
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
  // Background message received - Firebase handles display automatically
}
