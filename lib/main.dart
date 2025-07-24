import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:c2c_noc_events/theme.dart';
import 'package:c2c_noc_events/screens/main_navigation_screen.dart';
import 'package:c2c_noc_events/config/coda_config.dart';
import 'package:c2c_noc_events/services/fcm_service.dart';
import 'firebase_options.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C2C+NoC Events',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
    );
  }
}
