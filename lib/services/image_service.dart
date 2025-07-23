import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:c2c_noc_events/services/placeholder_image_service.dart';
import 'package:c2c_noc_events/services/image_cache_service.dart';
import 'package:c2c_noc_events/config/coda_config.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  /// Check if URL is a Coda-hosted image that needs authentication
  bool _isCodaHostedImage(String url) {
    return url.contains('codahosted.io');
  }

  /// Get headers for Coda-hosted images
  Map<String, String> _getCodaHeaders() {
    return {
      'Authorization': 'Bearer ${CodaConfig.apiToken}',
      'Accept': 'image/*,*/*',
    };
  }

  /// Get a category-specific color scheme for fallback images
  Color getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'PHONE BANK':
        return Colors.orange;
      case 'CANVASS':
        return Colors.cyan;
      case 'HYBRID':
        return Colors.purple;
      case 'MEETING':
        return Colors.blue;
      case 'TRAINING':
        return Colors.green;
      case 'COMMUNITY':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Create a gradient fallback widget for the given category
  Widget createCategoryFallback(String category, double height, double width) {
    final primaryColor = getCategoryColor(category);
    final secondaryColor = primaryColor.withValues(alpha: 0.3);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.8),
            secondaryColor,
            primaryColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: CategoryPatternPainter(primaryColor),
            ),
          ),
          // Category icon and text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 8),
                Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'PHONE BANK':
        return Icons.phone;
      case 'CANVASS':
        return Icons.door_front_door;
      case 'HYBRID':
        return Icons.groups;
      case 'MEETING':
        return Icons.meeting_room;
      case 'TRAINING':
        return Icons.school;
      case 'COMMUNITY':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  /// Build an enhanced network image with fallback
  Widget buildNetworkImage({
    required String imageUrl,
    required String category,
    required String title,
    double height = 140,
    double width = double.infinity,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    Widget fallbackWidget = createCategoryFallback(category, height, width);

    // Pre-cache the image in background
    ImageCacheService().downloadAndCacheImage(imageUrl);

    // Check if this is a Coda-hosted image that needs authentication
    Map<String, String>? headers;
    if (_isCodaHostedImage(imageUrl)) {
      headers = _getCodaHeaders();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: height,
        width: width,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          placeholder: (context, url) => Container(
            color: getCategoryColor(category).withValues(alpha: 0.3),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(getCategoryColor(category)),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            // Try a fallback URL first
            if (!url.contains('unsplash')) {
              final fallbackUrl = PlaceholderImageService().getFallbackImageUrl(category, title);

              return CachedNetworkImage(
                imageUrl: fallbackUrl,
                fit: fit,
                placeholder: (context, url) => Container(
                  color: getCategoryColor(category).withValues(alpha: 0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(getCategoryColor(category)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return fallbackWidget;
                },
                // Merge headers for fallback images too
                httpHeaders: {
                  'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
                  'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                  ...?headers, // Use same headers as main image
                },
              );
            }

            return fallbackWidget;
          },
          // Add headers - merge Coda auth with CORS headers
          httpHeaders: {
            'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
            'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
            ...?headers, // Spread Coda auth headers if present
          },
        ),
      ),
    );
  }
}

/// Custom painter for background patterns
class CategoryPatternPainter extends CustomPainter {
  final Color color;

  CategoryPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Create a subtle dot pattern
    final dotRadius = 2.0;
    final spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
