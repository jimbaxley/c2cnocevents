import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> testImageUrl(String url) async {
  print('Testing URL: $url');

  try {
    // Test with different headers
    final headers = {
      'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
      'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
    };

    print('Making HTTP request...');
    final response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    print('Status Code: ${response.statusCode}');
    print('Content-Type: ${response.headers['content-type']}');
    print('Content-Length: ${response.headers['content-length']}');

    if (response.statusCode == 200) {
      print('✅ SUCCESS: Image loaded successfully');
      print('Image size: ${response.bodyBytes.length} bytes');
    } else {
      print('❌ FAILED: HTTP ${response.statusCode}');
      if (response.body.length < 500) {
        print('Response body: ${response.body}');
      } else {
        print('Response body (first 200 chars): ${response.body.substring(0, 200)}...');
      }
    }
  } catch (e) {
    print('❌ ERROR: $e');
    print('Error type: ${e.runtimeType}');
  }
}

Future<void> testCodaImageUrls() async {
  print('🔍 Testing Coda API and Image URLs...\n');

  // Read Coda config (you may need to set these environment variables)
  const apiToken = String.fromEnvironment('CODA_API_TOKEN');
  const docId = String.fromEnvironment('CODA_DOC_ID');
  const tableId = String.fromEnvironment('CODA_TABLE_ID');

  if (apiToken.isEmpty || docId.isEmpty || tableId.isEmpty) {
    print('⚠️  Coda credentials not found in environment variables.');
    print(
        'Please run with: dart run test_images.dart --dart-define=CODA_API_TOKEN=your_token --dart-define=CODA_DOC_ID=your_doc --dart-define=CODA_TABLE_ID=your_table');
    print('\nTesting with sample URLs instead...\n');

    // Test some sample URLs that might be in your Coda
    final sampleUrls = [
      'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&h=400&fit=crop',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop',
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=400&fit=crop',
    ];

    for (final url in sampleUrls) {
      print('\n${'=' * 60}');
      await testImageUrl(url);
      await Future.delayed(const Duration(seconds: 1));
    }
    return;
  }

  try {
    // Fetch data from Coda
    print('📡 Fetching events from Coda...');
    final url = Uri.parse('https://coda.io/apis/v1/docs/$docId/tables/$tableId/rows');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rows = data['items'] as List;
      print('✅ Found ${rows.length} events in Coda');

      // Extract and test image URLs
      for (int i = 0; i < rows.length && i < 3; i++) {
        // Test first 3 events
        final row = rows[i];
        final values = row['values'] as Map<String, dynamic>;

        print('\n--- Event ${i + 1} ---');
        print('Available columns: ${values.keys.toList()}');

        // Check different possible image columns
        final urlColumn = values['c-65xmsGtRJz']; // Your URL column
        final graphicColumn = values['c-UqzlogrqaZ']; // Graphic column

        print('URL column (c-65xmsGtRJz): $urlColumn');
        print('Graphic column (c-UqzlogrqaZ): $graphicColumn');

        // Extract URL from the URL column
        String? imageUrl;
        if (urlColumn != null) {
          if (urlColumn is String) {
            imageUrl = urlColumn;
          } else if (urlColumn is Map) {
            imageUrl = urlColumn['url']?.toString() ??
                urlColumn['href']?.toString() ??
                urlColumn['display']?.toString() ??
                urlColumn['value']?.toString();
          }
        }

        if (imageUrl != null && imageUrl.isNotEmpty) {
          print('\n🔗 Testing extracted URL: $imageUrl');
          await testImageUrl(imageUrl);
        } else {
          print('❌ No valid image URL found in this event');
        }

        print('\n${'=' * 60}');
        await Future.delayed(const Duration(seconds: 2));
      }
    } else {
      print('❌ Failed to fetch from Coda: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error fetching from Coda: $e');
  }
}

void main() async {
  await testCodaImageUrls();
}
