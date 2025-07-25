import 'package:flutter/material.dart';
import 'package:c2c_noc_events/services/notification_service.dart';
import 'package:c2c_noc_events/services/event_service.dart';
import 'package:c2c_noc_events/models/notification_preference.dart';
import 'package:c2c_noc_events/models/event.dart';
import 'package:intl/intl.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool isSubscribedToEvents = true; // Events is subscribed by default
  bool isSubscribedToPhoneBanks = false;
  bool isSubscribedToCanvassing = false;

  void _toggleSubscription(String topic, bool subscribe) {
    setState(() {
      switch (topic) {
        case 'events':
          isSubscribedToEvents = subscribe;
          break;
        case 'phone_banks':
          isSubscribedToPhoneBanks = subscribe;
          break;
        case 'canvassing':
          isSubscribedToCanvassing = subscribe;
          break;
      }
      // Call your notification service to subscribe/unsubscribe to FCM topic here
      // NotificationService.subscribeToTopic(topic, subscribe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Events'),
            subtitle: const Text('General event notifications'),
            value: isSubscribedToEvents,
            onChanged: (val) => _toggleSubscription('events', val),
          ),
          SwitchListTile(
            title: const Text('Phone Banks'),
            subtitle: const Text('Phone banking events'),
            value: isSubscribedToPhoneBanks,
            onChanged: (val) => _toggleSubscription('phone_banks', val),
          ),
          SwitchListTile(
            title: const Text('Canvassing'),
            subtitle: const Text('Door-to-door canvassing'),
            value: isSubscribedToCanvassing,
            onChanged: (val) => _toggleSubscription('canvassing', val),
          ),
        ],
      ),
    );
  }
}
