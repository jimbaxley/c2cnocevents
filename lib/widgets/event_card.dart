import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_up_nc/models/event.dart';
import 'package:team_up_nc/services/image_service.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;
import 'package:timezone/timezone.dart' as tz;

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onSignUp;
  final VoidCallback? onNotification;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onSignUp,
    this.onNotification,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isDetailsExpanded = false;

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'PHONE BANK':
        return const Color(0xFF2499FF); // Bright Blue
      case 'CANVASS':
        return const Color(0xFF982F7A); // Accent
      case 'HYBRID':
        return const Color(0xFF5C3A88); // Purple
      case 'MEETING':
        return const Color(0xFF233C7E); // Main
      case 'SOCIAL':
        return const Color(0xFFFF00DF); // Pink
      case 'TRAINING':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getSignUpButtonColor(String category) {
    switch (category.toUpperCase()) {
      case 'PHONE BANK':
        return const Color(0xFF2499FF); // Bright Blue
      case 'CANVASS':
        return const Color(0xFF982F7A); // Accent
      case 'HYBRID':
        return const Color(0xFF5C3A88); // Purple
      case 'MEETING':
        return const Color(0xFF233C7E); // Main
      case 'SOCIAL':
        return const Color(0xFFFF00DF); // Pink
      case 'TRAINING':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1200 / 630, // Original image ratio: 1200x630 ≈ 1.905
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: ImageService().buildNetworkImage(
              imageUrl: widget.event.imageUrl,
              category: widget.event.category,
              title: widget.event.title,
              height: 200, // Provide a height, though AspectRatio will override it
              width: double.infinity,
              fit: BoxFit.cover, // Ensure the image covers the entire area
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.event.category.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            widget.event.title.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF233C7E), // Main color
              letterSpacing: 0.5,
              height: 1.2, // Tighter line spacing
            ),
            maxLines: 3, // Allow more lines for wrapping
          ),
          const SizedBox(height: 12),

          // Date and time
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Builder(
                builder: (context) {
                  final eastern = tz.getLocation('America/New_York');
                  final startDateEastern = tz.TZDateTime.from(widget.event.startDate.toUtc(), eastern);
                  String dateStr = DateFormat('MMM d, yyyy').format(startDateEastern);
                  String timeStr;
                  if (widget.event.startTime != null && widget.event.startTime!.isNotEmpty) {
                    timeStr = widget.event.startTime!;
                  } else {
                    timeStr = DateFormat('h:mm a').format(startDateEastern);
                  }
                  return Text(
                    '$dateStr | $timeStr ET',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    height: 1.3, // Tighter line spacing
                  ),
                  maxLines: 2, // Allow wrapping for location
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Details expansion tile (only show if details exist)
          if (widget.event.details != null && widget.event.details!.isNotEmpty) _buildDetailsSection(context),

          const SizedBox(height: 16),

          // Action buttons row
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add to Calendar button

              OutlinedButton.icon(
                onPressed: () {
                  final eastern = tz.getLocation('America/New_York');
                  final startDateEastern = tz.TZDateTime.from(widget.event.startDate.toUtc(), eastern);
                  // If startTime is present, try to parse it for calendar event
                  DateTime startDateTime = startDateEastern;
                  if (widget.event.startTime != null && widget.event.startTime!.isNotEmpty) {
                    try {
                      final parsedTime = DateFormat('h:mm a').parse(widget.event.startTime!);
                      startDateTime = DateTime(
                        startDateEastern.year,
                        startDateEastern.month,
                        startDateEastern.day,
                        parsedTime.hour,
                        parsedTime.minute,
                      );
                    } catch (_) {
                      // Fallback to original startDateEastern if parsing fails
                    }
                  }
                  final endDateEastern = tz.TZDateTime.from(
                    widget.event.endDate.toUtc(),
                    eastern,
                  );
                  final calendarEvent = add2cal.Event(
                    title: widget.event.title,
                    description: widget.event.description,
                    location: widget.event.location,
                    startDate: startDateTime,
                    endDate: endDateEastern,
                  );
                  add2cal.Add2Calendar.addEvent2Cal(calendarEvent);
                },
                icon: Icon(
                  Icons.calendar_today,
                  size: 16,
                ),
                label: Text(
                  'ADD TO CALENDAR',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _getCategoryColor(widget.event.category),
                  side: BorderSide(
                    color: _getCategoryColor(widget.event.category),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              // Sign up button
              ElevatedButton(
                onPressed: widget.onSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getSignUpButtonColor(widget.event.category),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SIGN UP NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isDetailsExpanded = !_isDetailsExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: _getCategoryColor(widget.event.category),
                ),
                const SizedBox(width: 8),
                Text(
                  'Details',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getCategoryColor(widget.event.category),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isDetailsExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: _getCategoryColor(widget.event.category),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isDetailsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getCategoryColor(widget.event.category).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              widget.event.details ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
