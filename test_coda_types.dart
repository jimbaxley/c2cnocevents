import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Your Coda credentials
  const apiToken = 'f3ea3f3d-6e5b-4b5b-9bfb-36b19a40863a';
  const docId = 'OySK5JOQh-';
  const tableId = 'table-X_KTN98R_x';

  print('🔍 Testing Type Values in Coda');
  print('============================================================');

  try {
    // Fetch all rows to see Type values
    final url = Uri.parse('https://coda.io/apis/v1/docs/$docId/tables/$tableId/rows');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rows = data['items'] as List;

      final types = <String>{};

      print('📋 All Events with Type and Start Date:');
      for (final row in rows) {
        final values = row['values'] as Map<String, dynamic>;
        final type = values['c-8uKSA5h1P6']?.toString() ?? 'Unknown';
        final name = values['c-Yxqi55UM11']?.toString() ?? 'No Name';
        final startDate = values['c-xM1UXlWtET']?.toString() ?? 'No Date';

        types.add(type);
        print('  Type: $type | Name: $name | Start: $startDate');
      }

      print('');
      print('🏷️ Unique Type Values Found:');
      for (final type in types.toList()..sort()) {
        print('  - $type');
      }
    } else {
      print('❌ Error fetching rows: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
