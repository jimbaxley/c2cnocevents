import 'package:flutter/material.dart';
import '../services/notification_storage.dart';
import '../widgets/notification_detail_modal.dart';
import '../services/notification_service.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  bool isSubscribedToEvents = true;
  bool isSubscribedToPhoneBanks = false;
  bool isSubscribedToCanvassing = false;
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    NotificationStorage.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    NotificationStorage.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = NotificationStorage.notifications;
      _unreadCount = NotificationStorage.unreadCount;
    });
  }

  void _onNotificationsChanged() {
    if (mounted) {
      _loadNotifications();
    }
  }

  void _showNotificationMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;
    // Build dynamic notification items
    List<PopupMenuEntry<String>> menuItems = [];

    // Recent notifications header
    menuItems.add(const PopupMenuItem(
      enabled: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Text(
          'Recent Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    ));

    // Add real notifications or show empty state
    if (_notifications.isEmpty) {
      menuItems.add(const PopupMenuItem(
        enabled: false,
        child: ListTile(
          leading: Icon(Icons.inbox_outlined, size: 16),
          title: Text('No notifications yet', style: TextStyle(fontSize: 13, color: Colors.grey)),
          contentPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
          dense: true,
          minLeadingWidth: 12,
        ),
      ));
    } else {
      // Show up to 3 most recent notifications
      final recentNotifications = _notifications.take(3).toList();
      for (int i = 0; i < recentNotifications.length; i++) {
        final notification = recentNotifications[i];
        menuItems.add(PopupMenuItem(
          value: 'notification_${notification.id}',
          child: ListTile(
            leading: Icon(
              notification.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
              size: 16,
              color: notification.isRead ? Colors.grey : Colors.blue,
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(
              notification.timeAgo,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
            dense: true,
            minLeadingWidth: 12,
          ),
        ));
      }
    }

    // Add separator
    menuItems.add(const PopupMenuItem(
      enabled: false,
      child: Divider(height: 1),
    ));

    // Clear all option if there are notifications
    if (_notifications.isNotEmpty) {
      menuItems.add(PopupMenuItem(
        value: 'clear_all',
        child: ListTile(
          leading: const Icon(Icons.clear_all, size: 16, color: Colors.red),
          title: const Text(
            'Clear All',
            style: TextStyle(fontSize: 13, color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
          dense: true,
          minLeadingWidth: 12,
        ),
      ));

      menuItems.add(const PopupMenuItem(
        enabled: false,
        child: Divider(height: 1),
      ));
    }

    // Subscribed topics section
    menuItems.addAll([
      const PopupMenuItem(
        enabled: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            'Subscribed Topics',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ),
// Events topic
      PopupMenuItem(
        enabled: false,
        child: Row(
          children: [
            Icon(Icons.notifications_active, size: 16, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Events', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) => Switch(
                value: isSubscribedToEvents,
                onChanged: (val) {
                  setState(() => isSubscribedToEvents = val);
                  // Call your subscribe/unsubscribe logic here
                  NotificationService.subscribeToTopic('events', val);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
      // Events topic
      PopupMenuItem(
        enabled: false,
        child: Row(
          children: [
            Icon(Icons.phone, size: 16, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone Banks', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) => Switch(
                value: isSubscribedToPhoneBanks,
                onChanged: (val) {
                  setState(() => isSubscribedToPhoneBanks = val);
                  // Call your subscribe/unsubscribe logic here
                  NotificationService.subscribeToTopic('phonebanks', val);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
// Events topic
      PopupMenuItem(
        enabled: false,
        child: Row(
          children: [
            Icon(Icons.directions_walk, size: 16, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Canvassing', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) => Switch(
                value: isSubscribedToCanvassing,
                onChanged: (val) {
                  setState(() => isSubscribedToCanvassing = val);
                  // Call your subscribe/unsubscribe logic here
                  NotificationService.subscribeToTopic('canvassing', val);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    ]);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, // left
        offset.dy + size.height, // top (below the bell)
        offset.dx + size.width, // right
        offset.dy, // bottom
      ),
      items: menuItems,
    ).then((value) {
      if (value != null) {
        _handleMenuSelection(value);
      }
    });

    // Mark notifications as read when menu is opened
    NotificationStorage.markAllAsRead();
  }

  void _handleMenuSelection(String value) {
    if (value.startsWith('notification_')) {
      // Handle specific notification tap
      final notificationId = value.replaceFirst('notification_', '');
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => NotificationItem(
          id: 'not_found',
          title: 'Notification not found',
          body: 'This notification could not be found.',
          timestamp: DateTime.now(),
        ),
      );

      // Show notification detail modal
      showNotificationModal(context, notification);
      return;
    }
    _showClearAllConfirmation();
    switch (value) {
      case 'clear_all':
        _showClearAllConfirmation();
        break;
    }
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: Text(
            'Are you sure you want to delete all ${_notifications.length} notifications? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                NotificationStorage.clearAllNotifications();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.onSurface,
          ),
          onPressed: _showNotificationMenu,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
