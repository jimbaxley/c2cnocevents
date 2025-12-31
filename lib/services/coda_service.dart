import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:team_up_nc/models/event.dart';
import 'package:team_up_nc/config/coda_config.dart';
import 'package:timezone/timezone.dart' as tz;

class CodaService {
  static final CodaService _instance = CodaService._internal();
  factory CodaService() => _instance;
  CodaService._internal();

  static const String _baseUrl = 'https://coda.io/apis/v1';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${CodaConfig.apiToken}',
        'Content-Type': 'application/json',
      };

  /// Fetch events from Coda table - simplified version
  Future<List<Event>> fetchEventsFromCoda() async {
    if (!CodaConfig.isConfigured) {
      throw Exception('Coda is not properly configured. Please set your API token, doc ID, and table ID.');
    }

    try {
      final url = Uri.parse('$_baseUrl/docs/${CodaConfig.docId}/tables/${CodaConfig.tableId}/rows');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rows = data['items'] as List;

        final List<Event> events = [];
        for (final row in rows) {
          try {
            final event = _parseBasicEvent(row);
            events.add(event);
          } catch (e) {
            // Continue with other rows if one fails to parse
          }
        }

        return events;
      } else {
        throw Exception('Failed to fetch events from Coda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching events from Coda: $e');
    }
  }

  /// Parse a Coda row into an Event object - basic version
  Event _parseBasicEvent(Map<String, dynamic> row) {
    final values = row['values'] as Map<String, dynamic>;

    // Get category (Type column) - c-8uKSA5h1P6
    final rawCategory = _getSimpleValue(values, 'c-8uKSA5h1P6') ?? 'GENERAL';
    final category = _normalizeCategory(rawCategory);

    // Try to get image from URL column first, then Graphic column, then fall back to category default
    final directUrl = _getSimpleValue(values, 'c-65xmsGtRJz');
    final graphicUrl = _getSimpleValue(values, 'c-UqzlogrqaZ');
    final imageUrl = (directUrl != null && directUrl.isNotEmpty)
        ? directUrl
        : (graphicUrl != null && graphicUrl.isNotEmpty)
            ? graphicUrl
            : _getDefaultImage(category);

    return Event(
      id: row['id'] ?? '',
      title: _getSimpleValue(values, 'c-Yxqi55UM11') ?? 'Untitled Event',
      description: _getSimpleValue(values, 'c-CuhtPto9h7') ?? '',
      startDate: _parseDate(_getSimpleValue(values, 'c-xM1UXlWtET')),
      endDate: _parseDate(_getSimpleValue(values, 'c-aZDbH3zhAy')),
      startTime: Event.extractTime(_getSimpleValue(values, 'c-AroDWMdVwY')),
      endTime: Event.extractTime(_getSimpleValue(values, 'c-qS63ogq8vX')),
      location: _getSimpleValue(values, 'c-208f9ghsIT') ?? '',
      imageUrl: imageUrl,
      category: category,
      organizerName: '',
      price: 0.0,
      maxAttendees: 0,
      currentAttendees: 0,
      tags: [],
      signUpUrl: _getSimpleValue(values, 'c-oQ9f2MSLrG'), // Sign up URL column
      details: _getSimpleValue(values, 'c-CuhtPto9h7'), // Details column
    );
  }

  /// Simple value extraction with special handling for images
  String? _getSimpleValue(Map<String, dynamic> values, String columnId) {
    final value = values[columnId];
    if (value == null) return null;

    // Handle simple cases first
    if (value is String) return value;
    if (value is num) return value.toString();

    // Handle object cases - Coda often wraps values in objects
    if (value is Map) {
      // For URL columns, try URL-specific fields first
      if (columnId == 'c-65xmsGtRJz') {
        // Direct URL column
        final urlValue = value['url']?.toString() ??
            value['href']?.toString() ??
            value['link']?.toString() ??
            value['display']?.toString() ??
            value['value']?.toString() ??
            value['text']?.toString();

        return urlValue;
      }

      // For image URLs, Coda might store them differently
      if (columnId == 'c-UqzlogrqaZ') {
        // Graphic column
        // Try different possible keys for image URLs
        final imageUrl = value['url']?.toString() ??
            value['src']?.toString() ??
            value['href']?.toString() ??
            value['display']?.toString() ??
            value['value']?.toString() ??
            value['text']?.toString();

        return imageUrl;
      }

      // For other columns, use standard extraction
      return value['display']?.toString() ?? value['value']?.toString() ?? value['text']?.toString();
    }

    // Handle arrays - take the first item if it's an array
    if (value is List && value.isNotEmpty) {
      final firstItem = value.first;
      if (firstItem is Map) {
        // For URL columns, prioritize URL fields
        if (columnId == 'c-65xmsGtRJz') {
          return firstItem['url']?.toString() ??
              firstItem['href']?.toString() ??
              firstItem['link']?.toString() ??
              firstItem['display']?.toString() ??
              firstItem['value']?.toString() ??
              firstItem['text']?.toString();
        }
        // For other columns including images
        return firstItem['url']?.toString() ??
            firstItem['display']?.toString() ??
            firstItem['value']?.toString() ??
            firstItem['text']?.toString();
      }
      return firstItem.toString();
    }

    return value.toString();
  }

  /// Parse date and convert from UTC to Eastern Time using timezone package
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();

    try {
      // Parse the date string (Coda typically returns UTC timestamps)
      DateTime utcDate = DateTime.parse(dateStr).toUtc();

      // Convert from UTC to Eastern Time using timezone package
      final eastern = tz.getLocation('America/New_York');
      final easternTime = tz.TZDateTime.from(utcDate, eastern);

      return easternTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Normalize category names from Coda to consistent format
  String _normalizeCategory(String rawCategory) {
    switch (rawCategory.toUpperCase().trim()) {
      case 'PHONE BANK':
      case 'PHONEBANK':
        return 'PHONE BANK';
      case 'CANVASS':
      case 'CANVASSING':
        return 'CANVASS';
      case 'HYBRID':
        return 'HYBRID';
      case 'MEETING':
      case 'MEETINGS':
        return 'MEETING';
      default:
        return rawCategory.toUpperCase();
    }
  }

  /// Get a category-specific default image
  String _getDefaultImage(String category) {
    switch (category.toUpperCase()) {
      case 'PHONE BANK':
        return 'https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=800&h=400&fit=crop'; // Phone/communication
      case 'CANVASS':
        return 'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=800&h=400&fit=crop'; // Door-to-door/community
      case 'HYBRID':
        return 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=400&fit=crop'; // Mixed/technology
      case 'MEETING':
        return 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=400&fit=crop'; // Meeting room
      case 'TRAINING':
        return 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800&h=400&fit=crop'; // Education/training
      case 'COMMUNITY':
        return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop'; // Community event
      default:
        return 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&h=400&fit=crop'; // Generic event
    }
  }

  /// Create a new event in Coda (simplified)
  Future<void> createEventInCoda(Event event) async {
    if (!CodaConfig.isConfigured) {
      throw Exception('Coda is not properly configured');
    }
    // Implementation for creating events would go here
  }

  /// Update an existing event in Coda (simplified)
  Future<void> updateEventInCoda(Event event) async {
    if (!CodaConfig.isConfigured) {
      throw Exception('Coda is not properly configured');
    }
    // Implementation for updating events would go here
  }
}
