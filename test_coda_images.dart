import 'package:http/http.dart' as http;
import 'dart:convert';

class CodaImageTester {
  static const String _baseUrl = 'https://coda.io/apis/v1';

  // Coda credentials from .env.example
  static const String apiToken = 'f3ea3f3d-6e5b-4b5b-9bfb-36b19a40863a';
  static const String docId = 'OySK5JOQh-';
  static const String tableId = 'table-X_KTN98R_x';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      };

  Future<void> testCodaImageUrls() async {
    print('🔍 Testing Coda Image URLs');
    print('Doc ID: $docId');
    print('Table ID: $tableId');
    print('=' * 60);

    try {
      // Fetch data from Coda
      final url = Uri.parse('$_baseUrl/docs/$docId/tables/$tableId/rows');
      print('Fetching from: $url');

      final response = await http.get(url, headers: _headers);

      if (response.statusCode != 200) {
        print('❌ Failed to fetch Coda data: ${response.statusCode}');
        print('Response: ${response.body}');
        return;
      }

      final data = json.decode(response.body);
      final rows = data['items'] as List;

      print('✅ Found ${rows.length} events in Coda table');
      print('');

      for (int i = 0; i < rows.length && i < 3; i++) {
        // Test first 3 events
        final row = rows[i];
        final values = row['values'] as Map<String, dynamic>;

        print('Event ${i + 1}:');
        print('Row ID: ${row['id']}');
        print('Available columns: ${values.keys.toList()}');

        // Get title
        final title = _getSimpleValue(values, 'c-Yxqi55UM11') ?? 'Untitled Event';
        print('Title: $title');

        // Test URL column (c-65xmsGtRJz)
        final directUrl = _getSimpleValue(values, 'c-65xmsGtRJz');
        print('Direct URL column (c-65xmsGtRJz): $directUrl');
        if (directUrl != null && directUrl.isNotEmpty) {
          await testImageUrl(directUrl, 'Direct URL');
        }

        // Test Graphic column (c-UqzlogrqaZ)
        final graphicUrl = _getSimpleValue(values, 'c-UqzlogrqaZ');
        print('Graphic column (c-UqzlogrqaZ): $graphicUrl');
        if (graphicUrl != null && graphicUrl.isNotEmpty) {
          await testImageUrl(graphicUrl, 'Graphic URL');
        }

        print('');
        print('-' * 40);
        print('');
      }
    } catch (e) {
      print('❌ Error testing Coda URLs: $e');
    }
  }

  String? _getSimpleValue(Map<String, dynamic> values, String columnId) {
    final value = values[columnId];
    if (value == null) return null;

    // Handle simple cases first
    if (value is String) return value;
    if (value is num) return value.toString();

    // Handle object cases
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

        if (urlValue == null) {
          print('URL column structure: $value');
        }
        return urlValue;
      }

      // For image URLs, Coda might store them differently
      if (columnId == 'c-UqzlogrqaZ') {
        // Graphic column
        final imageUrl = value['url']?.toString() ??
            value['src']?.toString() ??
            value['href']?.toString() ??
            value['display']?.toString() ??
            value['value']?.toString() ??
            value['text']?.toString();

        if (imageUrl == null) {
          print('Graphic column structure: $value');
        }
        return imageUrl;
      }

      // For other columns, use standard extraction
      return value['display']?.toString() ?? value['value']?.toString() ?? value['text']?.toString();
    }

    // Handle arrays - take the first item if it's an array
    if (value is List && value.isNotEmpty) {
      final firstItem = value.first;
      if (firstItem is Map) {
        return firstItem['url']?.toString() ??
            firstItem['display']?.toString() ??
            firstItem['value']?.toString() ??
            firstItem['text']?.toString();
      }
      return firstItem.toString();
    }

    return value.toString();
  }

  Future<void> testImageUrl(String url, String source) async {
    print('  Testing $source: $url');

    try {
      final headers = {
        'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
      };

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('  ✅ SUCCESS: ${response.bodyBytes.length} bytes');
        print('  Content-Type: ${response.headers['content-type']}');
      } else {
        print('  ❌ FAILED: HTTP ${response.statusCode}');
        print('  Response: ${response.body.substring(0, 200)}...');
      }
    } catch (e) {
      print('  ❌ ERROR: $e');
    }
  }
}

void main() async {
  final tester = CodaImageTester();
  await tester.testCodaImageUrls();
}
