import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:c2c_noc_events/models/event.dart';
import 'package:c2c_noc_events/services/notification_service.dart';
import 'package:c2c_noc_events/models/notification_preference.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeScreen();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _loadNotificationState();
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  Future<void> _loadNotificationState() async {
    final preference = await _notificationService.getNotificationPreference(widget.event.id);
    setState(() {
      _isNotificationEnabled = preference?.isEnabled ?? false;
    });
  }

  Future<void> _toggleNotification() async {
    final isEnabled = !_isNotificationEnabled;

    if (isEnabled) {
      await _showNotificationDialog();
    } else {
      await _notificationService.cancelEventNotification(widget.event.id);
      final preference = NotificationPreference(
        eventId: widget.event.id,
        isEnabled: false,
        notifyBefore: const Duration(hours: 1),
        type: 'reminder',
      );
      await _notificationService.saveNotificationPreference(preference);
      setState(() => _isNotificationEnabled = false);
    }
  }

  Future<void> _showNotificationDialog() async {
    Duration selectedDuration = const Duration(hours: 1);

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('When would you like to be notified about "${widget.event.title}"?'),
            const SizedBox(height: 16),
            DropdownButton<Duration>(
              value: selectedDuration,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: Duration(minutes: 30), child: Text('30 minutes before')),
                DropdownMenuItem(value: Duration(hours: 1), child: Text('1 hour before')),
                DropdownMenuItem(value: Duration(hours: 2), child: Text('2 hours before')),
                DropdownMenuItem(value: Duration(hours: 24), child: Text('1 day before')),
                DropdownMenuItem(value: Duration(days: 3), child: Text('3 days before')),
              ],
              onChanged: (Duration? value) {
                if (value != null) {
                  selectedDuration = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedDuration),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _notificationService.scheduleEventNotification(widget.event, result);
      final preference = NotificationPreference(
        eventId: widget.event.id,
        isEnabled: true,
        notifyBefore: result,
        type: 'reminder',
      );
      await _notificationService.saveNotificationPreference(preference);
      setState(() => _isNotificationEnabled = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 Notification scheduled for ${widget.event.title}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _sendInstantNotification() async {
    await _notificationService.showInstantNotification(
      '🎉 ${widget.event.title}',
      'Don\'t forget about this amazing event!',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📱 Instant notification sent!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSignUp(Event event) async {
    // Check if the event has a sign-up URL
    if (event.signUpUrl != null && event.signUpUrl!.isNotEmpty) {
      try {
        final Uri url = Uri.parse(event.signUpUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          // Show error if URL cannot be launched
          _showSignUpDialog(event, 'Unable to open sign-up link');
        }
      } catch (e) {
        _showSignUpDialog(event, 'Invalid sign-up link');
      }
    } else {
      // Fallback to the original dialog if no URL is provided
      _showSignUpDialog(event, null);
    }
  }

  void _showSignUpDialog(Event event, String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Up for ${event.title}'),
        content:
            Text(errorMessage ?? 'This would typically redirect to an external sign-up form or registration page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Event Image
            if (widget.event.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.event.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.event,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.event,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Content overlay
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.event.category,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEventDetails(context),
        _buildDescription(context),
        _buildActionButtons(context),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildEventDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            Icons.calendar_today,
            'Date & Time',
            '${DateFormat('EEEE, MMM d, yyyy').format(widget.event.startDate)}\n${DateFormat('h:mm a').format(widget.event.startDate)} - ${DateFormat('h:mm a').format(widget.event.endDate)} ET',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.location_on,
            'Location',
            widget.event.location,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleSignUp(widget.event),
              icon: Icon(
                Icons.how_to_reg,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                'Sign Up for Event',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'About this event',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.event.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          if (widget.event.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.event.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final calendarEvent = add2cal.Event(
                  title: widget.event.title,
                  description: widget.event.description,
                  location: widget.event.location,
                  startDate: widget.event.startDate,
                  endDate: widget.event.endDate,
                );
                add2cal.Add2Calendar.addEvent2Cal(calendarEvent);
              },
              icon: Icon(
                Icons.calendar_today,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                'Add to Calendar',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
