import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c2c_noc_events/models/event.dart';
import 'package:c2c_noc_events/models/notification_preference.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _prefsKey = 'notification_preferences';
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  Future<void> initialize() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin?.initialize(initSettings);
  }

  Future<void> scheduleEventNotification(Event event, Duration notifyBefore) async {
    if (_flutterLocalNotificationsPlugin == null) return;

    final notificationTime = event.startDate.subtract(notifyBefore);

    if (notificationTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'event_notifications',
      'Event Notifications',
      channelDescription: 'Notifications for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // For now, we'll use show method for immediate notification
    // In a production app, you'd use a proper scheduler like timezone package
    await _flutterLocalNotificationsPlugin!.show(
      event.id.hashCode,
      '🎉 ${event.title}',
      'Starting ${_formatNotifyBefore(notifyBefore)} at ${event.location}',
      notificationDetails,
      payload: event.id,
    );
  }

  String _formatNotifyBefore(Duration duration) {
    if (duration.inDays > 0) {
      return 'in ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return 'in ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return 'in ${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  Future<void> cancelEventNotification(String eventId) async {
    if (_flutterLocalNotificationsPlugin == null) return;
    await _flutterLocalNotificationsPlugin!.cancel(eventId.hashCode);
  }

  Future<void> saveNotificationPreference(NotificationPreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getStringList(_prefsKey) ?? [];

    prefsJson.removeWhere((json) {
      final decoded = Map<String, dynamic>.from(Uri.splitQueryString(json));
      return decoded['eventId'] == preference.eventId;
    });

    prefsJson.add(_encodePreference(preference));
    await prefs.setStringList(_prefsKey, prefsJson);
  }

  Future<NotificationPreference?> getNotificationPreference(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getStringList(_prefsKey) ?? [];

    for (final json in prefsJson) {
      final decoded = Map<String, dynamic>.from(Uri.splitQueryString(json));
      if (decoded['eventId'] == eventId) {
        return NotificationPreference.fromJson({
          'eventId': decoded['eventId'],
          'isEnabled': decoded['isEnabled'] == 'true',
          'notifyBefore': int.parse(decoded['notifyBefore'] ?? '60'),
          'type': decoded['type'] ?? 'reminder',
        });
      }
    }
    return null;
  }

  Future<List<NotificationPreference>> getAllNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getStringList(_prefsKey) ?? [];

    return prefsJson.map((json) {
      final decoded = Map<String, dynamic>.from(Uri.splitQueryString(json));
      return NotificationPreference.fromJson({
        'eventId': decoded['eventId'],
        'isEnabled': decoded['isEnabled'] == 'true',
        'notifyBefore': int.parse(decoded['notifyBefore'] ?? '60'),
        'type': decoded['type'] ?? 'reminder',
      });
    }).toList();
  }

  String _encodePreference(NotificationPreference preference) {
    return Uri(queryParameters: {
      'eventId': preference.eventId,
      'isEnabled': preference.isEnabled.toString(),
      'notifyBefore': preference.notifyBefore.inMinutes.toString(),
      'type': preference.type,
    }).query;
  }

  Future<void> showInstantNotification(String title, String body) async {
    if (_flutterLocalNotificationsPlugin == null) return;

    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Instant notifications for events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin!.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }
}
