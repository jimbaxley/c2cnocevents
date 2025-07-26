import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
        'isRead': isRead,
      };

  factory NotificationItem.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    return NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?.title ?? 'No Title',
      body: notification?.body ?? 'No Body',
      timestamp: DateTime.now(),
      data: message.data.isNotEmpty ? Map<String, dynamic>.from(message.data) : null,
      isRead: false,
    );
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) => NotificationItem(
        id: map['id'],
        title: map['title'],
        body: map['body'],
        timestamp: DateTime.parse(map['timestamp']),
        data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
        isRead: map['isRead'] ?? false,
      );
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
  static const _prefsKey = 'notifications';

  static Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    _notifications
      ..clear()
      ..addAll(jsonList.map((jsonStr) => NotificationItem.fromMap(json.decode(jsonStr))));
    _notifyListeners();
  }

  static Future<void> saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notifications.map((n) => json.encode(n.toMap())).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }

  static List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  static int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static Future<void> addNotification(NotificationItem notification) async {
    print(
        '🔔 [NotificationStorage] addNotification called: Title=\\${notification.title}, Body=\\${notification.body}, Data=\\${notification.data}');
    _notifications.insert(0, notification);
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
    await saveNotifications();
    print('💾 [NotificationStorage] Notifications saved. Total count: \\${_notifications.length}');
    _notifyListeners();

    // Set the app badge to the unread count
    final unread = unreadCount;
    if (unread > 0) {
      FlutterAppBadger.updateBadgeCount(unread);
    } else {
      FlutterAppBadger.removeBadge();
    }
  }

  static Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      await saveNotifications();
      _notifyListeners();
    }
    // Set the app badge to the unread count
    final unread = unreadCount;
    if (unread > 0) {
      FlutterAppBadger.updateBadgeCount(unread);
    } else {
      FlutterAppBadger.removeBadge();
    }
  }

  static Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    await saveNotifications();
    _notifyListeners();
    FlutterAppBadger.removeBadge();
  }

  static Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await saveNotifications();
    _notifyListeners();
  }

  static Future<void> clearAllNotifications() async {
    _notifications.clear();
    await saveNotifications();
    _notifyListeners();
  }

  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
