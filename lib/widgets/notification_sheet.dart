import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Represents a single notification item
class NotificationItem {
  final String id;
  final String message;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.message,
    this.isRead = false,
  });
}

/// Notification sheet matching the Swift NotificationView
class NotificationSheet extends StatefulWidget {
  final List<NotificationItem> notifications;
  final void Function(String notificationId) onMarkRead;

  const NotificationSheet({
    super.key,
    required this.notifications,
    required this.onMarkRead,
  });

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.deepRed,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: widget.notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = widget.notifications[index];
                return InkWell(
                  onTap: () {
                    widget.onMarkRead(notification.id);
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.isRead ? 'Read' : 'New',
                          style: TextStyle(
                            fontSize: 12,
                            color: notification.isRead
                                ? Colors.grey
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
