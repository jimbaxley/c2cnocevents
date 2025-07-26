import 'package:flutter/material.dart';
import '../services/notification_storage.dart';

class NotificationDetailModal extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailModal({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and close button
            Row(
              children: [
                Icon(
                  notification.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                  color: notification.isRead ? Colors.grey : Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 4),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  notification.body.isNotEmpty ? notification.body : 'No additional details available.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Timestamp
            Text(
              'Received',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${notification.timeAgo} • ${_formatDateTime(notification.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delete button on the left
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(context, notification);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

                // Mark as read and close buttons on the right
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;

    if (isToday) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  void _showDeleteConfirmation(BuildContext context, NotificationItem notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: Text(
            'Are you sure you want to delete this notification?\n\n"${notification.title}"',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                NotificationStorage.deleteNotification(notification.id);
                Navigator.of(context).pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close notification modal
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Helper function to show the modal
void showNotificationModal(BuildContext context, NotificationItem notification) {
  // Defensive: check if context is mounted (for StatefulElement)
  if (context is StatefulElement && !context.mounted) {
    return;
  }
  // Mark as read automatically on open
  if (!notification.isRead) {
    NotificationStorage.markAsRead(notification.id);
  }
  showDialog(
    context: context,
    builder: (context) => NotificationDetailModal(notification: notification),
  );
}
