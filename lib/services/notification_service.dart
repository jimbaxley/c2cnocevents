import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static Future<void> subscribeToTopic(String topic, bool subscribe) async {
    debugPrint('🔔 NotificationService: ${subscribe ? "Subscribing to" : "Unsubscribing from"} topic: $topic');
    
    if (subscribe) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('subscribed_$topic', subscribe);
    debugPrint('💾 Saved subscription preference for $topic: $subscribe');
  }

  static Future<bool> isSubscribedToTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    // Default: general=true, others=false
    if (!prefs.containsKey('subscribed_$topic')) {
      if (topic == 'general') return true;
      return false;
    }
    return prefs.getBool('subscribed_$topic') ?? false;
  }
}
