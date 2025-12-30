import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static Future<void> subscribeToTopic(String topic, bool subscribe) async {
    print('🔔 NotificationService: ${subscribe ? "Subscribing to" : "Unsubscribing from"} topic: $topic');
    
    if (subscribe) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('subscribed_$topic', subscribe);
    print('💾 Saved subscription preference for $topic: $subscribe');
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
