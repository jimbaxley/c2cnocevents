import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.data,
    this.isRead = false,
  });

  factory NotificationItem.fromRemoteMessage(RemoteMessage message) {
    return NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? 'New notification',
      timestamp: DateTime.now(),
      data: message.data,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class NotificationStorage {
  static final List<NotificationItem> _notifications = [];
  static final List<Function()> _listeners = [];

  static List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  static int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification); // Add to beginning

    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    _notifyListeners();
  }

  static void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      _notifyListeners();
    }
  }

  static void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _notifyListeners();
  }

  static void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notifyListeners();
  }

  static void clearAllNotifications() {
    _notifications.clear();
    _notifyListeners();
  }

  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // For testing - add some sample notifications
  static void addSampleNotifications() {
    addNotification(NotificationItem(
      id: 'sample_1',
      title: 'New Event: Phone Bank Tonight',
      body:
          'Join us for phone banking tonight at 7 PM. We\'ll be calling voters in key districts to increase turnout for the upcoming election. Pizza and drinks will be provided. Please bring your phone and a positive attitude!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      data: {
        'event_type': 'phone_bank',
        'location': 'Campaign Office',
        'time': '19:00',
      },
    ));

    addNotification(NotificationItem(
      id: 'sample_2',
      title: 'Reminder: Canvas Tomorrow',
      body:
          'Don\'t forget about canvassing tomorrow at 10 AM. We\'ll be going door-to-door in the Riverside neighborhood. Meet at the community center for training and materials. Comfortable shoes recommended!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      data: {
        'event_type': 'canvass',
        'location': 'Riverside Community Center',
        'time': '10:00',
        'neighborhood': 'Riverside',
      },
    ));

    addNotification(NotificationItem(
      id: 'sample_3',
      title: 'Event Update: Rally Moved Indoors',
      body:
          'Due to weather conditions, tonight\'s rally has been moved indoors to the high school gymnasium. All other details remain the same. Doors open at 6 PM, event starts at 7 PM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      data: {
        'event_type': 'rally',
        'old_location': 'City Park',
        'new_location': 'High School Gymnasium',
        'reason': 'weather',
      },
    ));
  }
}
