import 'dart:convert';

class PlaceholderImageService {
  static final PlaceholderImageService _instance = PlaceholderImageService._internal();
  factory PlaceholderImageService() => _instance;
  PlaceholderImageService._internal();

  /// Generate a data URL for a placeholder SVG image
  String generatePlaceholderDataUrl(String category, String title) {
    final color = _getCategoryHexColor(category);
    final icon = _getCategoryIcon(category);

    final svg = '''
<svg width="400" height="200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:$color;stop-opacity:0.8" />
      <stop offset="50%" style="stop-color:$color;stop-opacity:0.6" />
      <stop offset="100%" style="stop-color:$color;stop-opacity:0.9" />
    </linearGradient>
    <pattern id="dots" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
      <circle cx="10" cy="10" r="1" fill="white" opacity="0.1"/>
    </pattern>
  </defs>
  <rect width="100%" height="100%" fill="url(#bg)"/>
  <rect width="100%" height="100%" fill="url(#dots)"/>
  <g transform="translate(200,100)">
    <text x="0" y="-20" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="14" font-weight="bold" opacity="0.9">
      $icon
    </text>
    <text x="0" y="0" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="12" font-weight="bold">
      ${category.toUpperCase()}
    </text>
    <text x="0" y="20" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="10" opacity="0.8">
      ${title.length > 30 ? '${title.substring(0, 30)}...' : title}
    </text>
  </g>
</svg>''';

    final encoded = base64Encode(utf8.encode(svg));
    return 'data:image/svg+xml;base64,$encoded';
  }

  String _getCategoryHexColor(String category) {
    switch (category.toUpperCase()) {
      case 'PHONE BANK':
        return '#FF9800'; // Orange
      case 'CANVASS':
        return '#00BCD4'; // Cyan
      case 'HYBRID':
        return '#9C27B0'; // Purple
      case 'MEETING':
        return '#2196F3'; // Blue
      case 'TRAINING':
        return '#4CAF50'; // Green
      case 'COMMUNITY':
        return '#009688'; // Teal
      default:
        return '#757575'; // Grey
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'PHONE BANK':
        return '📞';
      case 'CANVASS':
        return '🚪';
      case 'HYBRID':
        return '👥';
      case 'MEETING':
        return '🏢';
      case 'TRAINING':
        return '🎓';
      case 'COMMUNITY':
        return '🌟';
      default:
        return '📅';
    }
  }

  /// Get a fallback URL for events with problematic images
  String getFallbackImageUrl(String category, String title) {
    // Try some reliable image sources first
    final fallbackUrls = [
      'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&h=400&fit=crop', // Generic event
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop', // Community
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=400&fit=crop', // Meeting
    ];

    // Return the first fallback for now, but this could be category-specific
    return fallbackUrls[0];
  }
}
