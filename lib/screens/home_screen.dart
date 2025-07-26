import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:c2c_noc_events/models/event.dart';
import 'package:c2c_noc_events/services/event_service.dart';
//import 'package:c2c_noc_events/services/notification_service.dart';
import 'package:c2c_noc_events/widgets/event_card.dart';
import 'package:c2c_noc_events/widgets/notification_bell.dart';
import 'package:c2c_noc_events/screens/learn_more_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final EventService _eventService = EventService();
  //final NotificationService _notificationService = NotificationService();

  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // await _notificationService.initialize();
    await _loadEvents();
    _fadeController.forward();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.getEvents();
      setState(() {
        _events = events;
        _filteredEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
    }
  }

  void _filterEvents() {
    setState(() {
      _filteredEvents = _events.where((event) {
        final matchesCategory = _selectedCategory == 'All' || event.category == _selectedCategory;
        return matchesCategory;
      }).toList();
    });
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
          if (mounted) _showSignUpDialog(event, 'Unable to open sign-up link');
        }
      } catch (e) {
        // Remove print statement for production
        if (mounted) _showSignUpDialog(event, 'Invalid sign-up link');
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
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(context),
              _buildCategoryFilter(context),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(context)
                    : _filteredEvents.isEmpty
                        ? _buildEmptyState(context)
                        : _buildEventsList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'C2C+NoC',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.info_outline, color: colorScheme.primary),
                      tooltip: 'Learn More',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LearnMoreScreen()),
                        );
                      },
                      padding: EdgeInsets.zero, // keeps icon close to text
                      constraints: BoxConstraints(), // removes extra space
                    ),
                  ],
                ),
              ],
            ),
          ),
          const NotificationBell(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = ['All', ..._eventService.categories];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              _filterEvents();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or category filter',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          return EventCard(
            event: event,
            onSignUp: () => _handleSignUp(event),
            //onNotification: () => _toggleNotification(event),
          );
        },
      ),
    );
  }
}
