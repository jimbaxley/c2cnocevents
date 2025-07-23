import 'package:flutter/material.dart';
import 'package:c2c_noc_events/services/event_service.dart';
import 'package:c2c_noc_events/services/coda_service.dart';
import 'package:c2c_noc_events/config/coda_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodaSettingsScreen extends StatefulWidget {
  const CodaSettingsScreen({super.key});

  @override
  State<CodaSettingsScreen> createState() => _CodaSettingsScreenState();
}

class _CodaSettingsScreenState extends State<CodaSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiTokenController = TextEditingController();
  final _docIdController = TextEditingController();
  final _tableIdController = TextEditingController();
  bool _codaEnabled = false;
  bool _isLoading = false;
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiTokenController.text = prefs.getString('coda_api_token') ?? '';
      _docIdController.text = prefs.getString('coda_doc_id') ?? '';
      _tableIdController.text = prefs.getString('coda_table_id') ?? '';
      _codaEnabled = prefs.getBool('coda_enabled') ?? false;
    });
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _connectionStatus = null;
    });

    // Store original credentials
    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('coda_api_token');
    final oldDocId = prefs.getString('coda_doc_id');
    final oldTableId = prefs.getString('coda_table_id');

    try {
      // Temporarily save credentials to test
      await prefs.setString('coda_api_token', _apiTokenController.text);
      await prefs.setString('coda_doc_id', _docIdController.text);
      await prefs.setString('coda_table_id', _tableIdController.text);

      // Test the connection
      final codaService = CodaService();
      final events = await codaService.fetchEventsFromCoda();

      setState(() {
        _connectionStatus = 'Success! Found ${events.length} events in your Coda table.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: ${e.toString()}';
        _isLoading = false;
      });

      // Restore old credentials on failure
      if (oldToken != null) await prefs.setString('coda_api_token', oldToken);
      if (oldDocId != null) await prefs.setString('coda_doc_id', oldDocId);
      if (oldTableId != null) await prefs.setString('coda_table_id', oldTableId);
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('coda_api_token', _apiTokenController.text);
      await prefs.setString('coda_doc_id', _docIdController.text);
      await prefs.setString('coda_table_id', _tableIdController.text);
      await prefs.setBool('coda_enabled', _codaEnabled);

      // Update CodaConfig with new credentials
      await CodaConfig.updateConfig(
        apiToken: _apiTokenController.text,
        docId: _docIdController.text,
        tableId: _tableIdController.text,
      );

      // Update EventService
      await EventService().setCodaEnabled(_codaEnabled);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coda Integration Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configure Coda Integration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Setup Instructions:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('1. Create a Coda document with an events table'),
                        const Text('2. Add these columns to your table:'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Required Columns:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('• Title (Text) - Event name'),
                              Text('• Description (Text) - Event details'),
                              Text('• Start Date (Date) - When event starts'),
                              Text('• End Date (Date) - When event ends'),
                              Text('• Location (Text) - Event location'),
                              Text('• Category (Text) - Event type'),
                              Text('• Organizer (Text) - Who\'s organizing'),
                              SizedBox(height: 8),
                              Text('Optional Columns:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('• Image URL (URL) - Event image'),
                              Text('• Price (Number) - Ticket price'),
                              Text('• Max Attendees (Number) - Capacity'),
                              Text('• Current Attendees (Number) - Registered'),
                              Text('• Tags (Text) - Comma-separated tags'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('3. Generate an API token in Coda Settings → API'),
                        const Text('4. Get your document ID from the Coda URL'),
                        const Text('5. Find your table ID using the Coda API'),
                        const Text('6. Test your connection using the button below'),
                        const Text('7. Enable Coda integration when ready'),
                        const SizedBox(height: 12),
                        ExpansionTile(
                          title: const Text('Sample Coda Table Structure'),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Create a table with these exact column names:',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text(
                                      'Title | Description | Start Date | End Date | Location | Category | Organizer | Image URL | Price | Max Attendees | Current Attendees | Tags'),
                                  SizedBox(height: 8),
                                  Text('Example row:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                      'Summer Festival | A fun community event | 2025-08-15 | 2025-08-15 | City Park | COMMUNITY | Parks Dept | https://example.com/image.jpg | 0 | 500 | 150 | festival,community,outdoor'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            // Could open documentation in web view
                          },
                          child: const Text('View Coda API Documentation'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Enable Coda Integration'),
                  subtitle: const Text('Use Coda as the data source for events'),
                  value: _codaEnabled,
                  onChanged: (value) {
                    setState(() {
                      _codaEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apiTokenController,
                  decoration: const InputDecoration(
                    labelText: 'Coda API Token',
                    hintText: 'Enter your Coda API token',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_codaEnabled && (value == null || value.isEmpty)) {
                      return 'API token is required when Coda is enabled';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _docIdController,
                  decoration: const InputDecoration(
                    labelText: 'Document ID',
                    hintText: 'Enter your Coda document ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_codaEnabled && (value == null || value.isEmpty)) {
                      return 'Document ID is required when Coda is enabled';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tableIdController,
                  decoration: const InputDecoration(
                    labelText: 'Table ID',
                    hintText: 'Enter your Coda table ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_codaEnabled && (value == null || value.isEmpty)) {
                      return 'Table ID is required when Coda is enabled';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testConnection,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Test Connection'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
                if (_connectionStatus != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: _connectionStatus!.startsWith('Success') ? Colors.green.shade50 : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            _connectionStatus!.startsWith('Success') ? Icons.check_circle : Icons.error,
                            color: _connectionStatus!.startsWith('Success') ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_connectionStatus!)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (CodaConfig.isConfigured)
                  Card(
                    color: Colors.green.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Coda is configured and ready to use'),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('Coda configuration incomplete. Using sample data.'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiTokenController.dispose();
    _docIdController.dispose();
    _tableIdController.dispose();
    super.dispose();
  }
}
