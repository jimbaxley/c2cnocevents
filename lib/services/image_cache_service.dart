import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:c2c_noc_events/config/coda_config.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, Uint8List> _memoryCache = {};
  static const String _cachePrefix = 'image_cache_';
  static const int _maxCacheAgeMinutes = 60; // Cache for 1 hour

  /// Check if URL is a Coda-hosted image that needs authentication
  bool _isCodaHostedImage(String url) {
    return url.contains('codahosted.io');
  }

  /// Get headers for image requests
  Map<String, String> _getImageHeaders(String url) {
    final baseHeaders = {
      'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
      'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
    };

    // Add Coda authentication if needed
    if (_isCodaHostedImage(url)) {
      baseHeaders['Authorization'] = 'Bearer ${CodaConfig.apiToken}';
    }

    return baseHeaders;
  }

  /// Download and cache an image locally
  Future<Uint8List?> downloadAndCacheImage(String url) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(url)) {
        return _memoryCache[url];
      }

      // Check persistent cache
      final cachedData = await _getCachedImage(url);
      if (cachedData != null) {
        _memoryCache[url] = cachedData;
        return cachedData;
      }

      // Download image
      final response = await http
          .get(
            Uri.parse(url),
            headers: _getImageHeaders(url),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;

        // Cache in memory
        _memoryCache[url] = imageData;

        // Cache persistently
        await _cacheImage(url, imageData);

        return imageData;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get cached image data
  Future<Uint8List?> _getCachedImage(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(url);
      final timestampKey = '${cacheKey}_timestamp';

      // Check if cache exists and is not expired
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        final maxAge = _maxCacheAgeMinutes * 60 * 1000; // Convert to milliseconds

        if (cacheAge > maxAge) {
          // Cache expired, remove it
          await prefs.remove(cacheKey);
          await prefs.remove(timestampKey);
          return null;
        }
      }

      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        return base64Decode(cachedData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache image data persistently
  Future<void> _cacheImage(String url, Uint8List data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(url);
      final timestampKey = '${cacheKey}_timestamp';

      // Convert to base64 for storage
      final base64Data = base64Encode(data);

      // Store data and timestamp
      await prefs.setString(cacheKey, base64Data);
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently handle caching errors
    }
  }

  /// Generate cache key from URL
  String _getCacheKey(String url) {
    return '$_cachePrefix${url.hashCode.abs()}';
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }

      _memoryCache.clear();
    } catch (e) {
      // Silently handle clear cache errors
    }
  }

  /// Get memory cache size for debugging
  int get memoryCacheSize => _memoryCache.length;

  /// Pre-cache multiple images (useful for loading screens)
  Future<void> precacheImages(List<String> urls) async {
    for (final url in urls) {
      if (!_memoryCache.containsKey(url)) {
        // Run in background without waiting
        downloadAndCacheImage(url);
      }
    }
  }
}
