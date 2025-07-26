import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:c2c_noc_events/theme.dart';
import 'package:c2c_noc_events/screens/main_navigation_screen.dart';
import 'package:c2c_noc_events/config/coda_config.dart';
import 'package:c2c_noc_events/services/fcm_service.dart';
import 'package:c2c_noc_events/services/notification_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:c2c_noc_events/widgets/notification_detail_modal.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupFCMListeners() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (navigatorKey.currentContext != null) {
      showNotificationModal(
        navigatorKey.currentContext!,
        NotificationItem.fromRemoteMessage(message),
      );
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        final retryCtx = navigatorKey.currentContext;
        if (retryCtx != null) {
          showNotificationModal(retryCtx, NotificationItem.fromRemoteMessage(message));
        }
      });
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null && navigatorKey.currentContext != null) {
      Future.delayed(const Duration(seconds: 1), () {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          showNotificationModal(ctx, NotificationItem.fromRemoteMessage(message));
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            final retryCtx = navigatorKey.currentContext;
            if (retryCtx != null) {
              showNotificationModal(retryCtx, NotificationItem.fromRemoteMessage(message));
            }
          });
        }
      });
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load configuration from Firebase Remote Config
  await CodaConfig.loadConfig();

  // Initialize Firebase Cloud Messaging
  await FCMService.initialize();

  // load notifications from storage
  await NotificationStorage.loadNotifications();

  // timezone initialization
  tzdata.initializeTimeZones();

  runApp(const MyApp());
  // Register FCM listeners after runApp so navigatorKey context is available
  setupFCMListeners();

  // Show modal for most recent unread notification if any
  if (NotificationStorage.unreadCount > 0 && NotificationStorage.notifications.isNotEmpty) {
    // Wait for navigatorKey context to be available
    Future.delayed(const Duration(seconds: 1), () {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        // Find the most recent unread notification
        final unread = NotificationStorage.notifications.where((n) => !n.isRead).toList();
        if (unread.isNotEmpty) {
          showNotificationModal(ctx, unread.first);
        }
      }
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // No FCM listeners here; handled globally after runApp
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'C2C+NoC Events',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
    );
  }
}
