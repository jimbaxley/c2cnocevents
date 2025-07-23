import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Your Coda credentials
  const apiToken = 'f3ea3f3d-6e5b-4b5b-9bfb-36b19a40863a';
  const docId = 'OySK5JOQh-';
  const tableId = 'table-X_KTN98R_x';

  print('🔍 Testing Coda Column Contents');
  print('Doc ID: $docId');
  print('Table ID: $tableId');
  print('============================================================');

  try {
    // Fetch table schema first
    final columnsUrl = Uri.parse('https://coda.io/apis/v1/docs/$docId/tables/$tableId/columns');
    final columnsResponse = await http.get(
      columnsUrl,
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
    );

    if (columnsResponse.statusCode == 200) {
      final columnsData = json.decode(columnsResponse.body);
      final columns = columnsData['items'] as List;

      print('📋 Available Columns:');
      for (final column in columns) {
        print('  ${column['id']}: ${column['name']} (${column['type']})');
      }
      print('');
    }

    // Fetch one row to see the data
    final url = Uri.parse('https://coda.io/apis/v1/docs/$docId/tables/$tableId/rows?limit=1');
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

      if (rows.isNotEmpty) {
        final firstRow = rows[0];
        final values = firstRow['values'] as Map<String, dynamic>;

        print('📄 First Row Data:');
        values.forEach((columnId, value) {
          print('  $columnId: $value');
        });
      }
    } else {
      print('❌ Error fetching rows: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
