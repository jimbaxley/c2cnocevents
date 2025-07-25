import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> subscribeToTopic(String topic, bool subscribe) async {
    if (subscribe) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
  }
}
