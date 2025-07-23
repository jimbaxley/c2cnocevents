import 'package:c2c_noc_events/models/event.dart';
import 'package:c2c_noc_events/services/coda_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal() {
    _loadCodaPreference();
  }

  final CodaService _codaService = CodaService();
  bool _useCoda = true; // Always use Coda by default now
  DateTime? _lastRefreshTime;

  /// Load Coda preference from SharedPreferences
  Future<void> _loadCodaPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _useCoda = prefs.getBool('coda_enabled') ?? true; // Default to true
  }

  final List<Event> _sampleEvents = [
    Event(
      id: '1',
      title: 'Sen. Terence Everitt (SD18) & Rep. Bryan Cohn (HD32)',
      description:
          'Kickoff event for the upcoming campaign season. Meet the candidates and learn about their platform.',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7, hours: 3)),
      location: 'Kickoff TUES. 7/8, 5:45-8:00 PM. CALLING 7/8-7/31',
      imageUrl:
          'https://pixabay.com/get/g34364606a3d4fd2ef7c15b2c894279f6ce27711311349bae8867e3ff7417c668389750d90d34fc2c1fb66dacd8d28607ca0512860b0888ba432ebac2fa488229_1280.jpg',
      category: 'PHONE BANK',
      organizerName: 'Democratic Party',
      maxAttendees: 500,
      currentAttendees: 342,
      tags: ['politics', 'campaign', 'phone bank', 'democratic'],
      details:
          'This is a crucial phone bank event to support our candidates. We\'ll be calling registered voters to discuss key issues and encourage participation. Training will be provided for new volunteers. Please bring your phone and a positive attitude!',
    ),
    Event(
      id: '2',
      title: 'Super Summer Shindig',
      description: 'Hosted by Hometown Holler. A fun summer event with music, food, and community activities.',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 14, hours: 4)),
      location: 'Lots of locations and on Zoom',
      imageUrl:
          'https://pixabay.com/get/gd4736b4c194eb5221539ab3788b4740782df12b491fdd5b3de88a4887e05f0350588e373b6e0a417070ad6bf28dfb07dee21a6b7af7274342c17d1c95b500552_1280.jpg',
      category: 'HYBRID',
      organizerName: 'Hometown Holler',
      maxAttendees: 2000,
      currentAttendees: 1756,
      tags: ['community', 'hybrid', 'summer', 'social'],
      details:
          'Join us for an amazing summer celebration! This hybrid event features live music, local food vendors, family-friendly activities, and community networking. Both in-person and virtual attendees can participate in interactive sessions, games, and prize drawings.',
    ),
    Event(
      id: '3',
      title: 'Nash GOP Accountability Canvass',
      description: 'Hold GOP legislators accountable. Door-to-door canvassing to engage with voters.',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 3, hours: 4)),
      location: 'Nash County Democratic Party HQ, 301 S Church St #101, Rocky Mount, NC',
      imageUrl:
          'https://pixabay.com/get/gdb531076edba9b29a733c9417007686981c016a8000f2a5fd995c24db6c1394a93fb2058c698763e0f0b188d2b4a429a6429c0a11ce66d49db06ce0ba7b62820_1280.jpg',
      category: 'CANVASS',
      organizerName: 'Nash County Democratic Party',
      maxAttendees: 100,
      currentAttendees: 78,
      tags: ['canvass', 'accountability', 'gop', 'door-to-door'],
    ),
    Event(
      id: '4',
      title: 'Phone Bank Party and Training',
      description: 'Learn how to effectively phone bank for democratic candidates. Training and calling session.',
      startDate: DateTime.now().add(const Duration(days: 21)),
      endDate: DateTime.now().add(const Duration(days: 21, hours: 3)),
      location: 'Democratic Party Headquarters',
      imageUrl:
          'https://pixabay.com/get/g2a2e9b9ae8952286fe72a4f18f120a08fbb8e501ed2361c0a1a16084c67f6970c9d25327efeb04c6b4ab1ce64496ebf0dbc95fa5c82a5407e845d00867f2184a_1280.jpg',
      category: 'PHONE BANK',
      organizerName: 'Democratic Party',
      maxAttendees: 800,
      currentAttendees: 623,
      tags: ['phone bank', 'training', 'democratic', 'calling'],
    ),
    Event(
      id: '5',
      title: 'Vance Co. GOTV Canvass',
      description:
          'Get out the vote canvassing in Vance County. Help increase voter turnout for the upcoming election.',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 10, hours: 4)),
      location: 'Henderson, Vance County',
      imageUrl:
          'https://pixabay.com/get/g97f2cd0fa1b615548b9f5d865389a571d1947b36ea5846e1ede38d6e31e48aad7ea4f19b860f1bc862a0954094bae37d268859607c13bda971a430b60c5e56db_1280.jpg',
      category: 'CANVASS',
      organizerName: 'Vance County Democrats',
      maxAttendees: 200,
      currentAttendees: 87,
      tags: ['gotv', 'canvass', 'vance county', 'voter turnout'],
    ),
    Event(
      id: '6',
      title: 'Nash Co. GOTV Canvass',
      description: 'Get out the vote canvassing in Nash County. Critical final push to increase voter participation.',
      startDate: DateTime.now().add(const Duration(days: 28)),
      endDate: DateTime.now().add(const Duration(days: 28, hours: 4)),
      location: 'Rocky Mount, Nash County',
      imageUrl:
          'https://pixabay.com/get/gbd22fcf1a82548a70d0b8f68d0b60334d7bef01acbd30f656aed5aed798f29d261446d90219133c6bc891d4e6fc28fb2121898298c722367dff0d19c15e6c017_1280.jpg',
      category: 'CANVASS',
      organizerName: 'Nash County Democrats',
      maxAttendees: 5000,
      currentAttendees: 3421,
      tags: ['gotv', 'canvass', 'nash county', 'election'],
    ),
  ];

  Future<List<Event>> getEvents() async {
    List<Event> events;

    if (_useCoda) {
      try {
        final codaEvents = await _codaService.fetchEventsFromCoda();
        if (codaEvents.isNotEmpty) {
          events = codaEvents;
        } else {
          // If Coda returns empty list, fall back to sample data
          await Future.delayed(const Duration(milliseconds: 500));
          events = _sampleEvents;
        }
      } catch (e) {
        // Fallback to sample data if Coda fails
        await Future.delayed(const Duration(milliseconds: 500));
        events = _sampleEvents;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      events = _sampleEvents;
    }

    // Update last refresh time
    _lastRefreshTime = DateTime.now();

    // Sort events by start date (ascending)
    events.sort((a, b) => a.startDate.compareTo(b.startDate));
    return events;
  }

  /// Toggle between Coda data source and sample data
  Future<void> setCodaEnabled(bool enabled) async {
    _useCoda = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('coda_enabled', enabled);
  }

  bool get isCodaEnabled => _useCoda;

  /// Get data source information with last refresh time
  String get dataSource {
    if (_lastRefreshTime == null) {
      return _useCoda ? 'Coda' : 'Sample Data';
    }
    final timeFormat = DateFormat('MMM d, h:mm a');
    return 'As of ${timeFormat.format(_lastRefreshTime!)}';
  }

  /// Get last refresh time
  DateTime? get lastRefreshTime => _lastRefreshTime;

  Future<Event?> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _sampleEvents.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sampleEvents.where((event) => event.category.toLowerCase() == category.toLowerCase()).toList();
  }

  Future<List<Event>> searchEvents(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowerQuery = query.toLowerCase();
    return _sampleEvents
        .where((event) =>
            event.title.toLowerCase().contains(lowerQuery) ||
            event.description.toLowerCase().contains(lowerQuery) ||
            event.category.toLowerCase().contains(lowerQuery) ||
            event.location.toLowerCase().contains(lowerQuery) ||
            event.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Get available categories
  List<String> get categories => _useCoda
      ? ['PHONE BANK', 'CANVASS', 'HYBRID', 'MEETING'] // Real Coda categories
      : _sampleEvents.map((e) => e.category).toSet().toList(); // Sample categories

  /// Create a new event (will use Coda if enabled)
  Future<void> createEvent(Event event) async {
    if (_useCoda) {
      await _codaService.createEventInCoda(event);
    } else {
      _sampleEvents.add(event);
    }
  }

  /// Update an existing event (will use Coda if enabled)
  Future<void> updateEvent(Event event) async {
    if (_useCoda) {
      await _codaService.updateEventInCoda(event);
    } else {
      final index = _sampleEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _sampleEvents[index] = event;
      }
    }
  }
}
