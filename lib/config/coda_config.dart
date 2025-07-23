import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class CodaConfig {
  // Default empty values - will be populated from Firebase Remote Config
  static String _apiToken = '';
  static String _docId = '';
  static String _tableId = '';

  static String get apiToken => _apiToken;
  static String get docId => _docId;
  static String get tableId => _tableId;

  static bool get isConfigured => _apiToken.isNotEmpty && _docId.isNotEmpty && _tableId.isNotEmpty;

  /// Load configuration from Firebase Remote Config, with SharedPreferences fallback
  static Future<void> loadConfig() async {
    try {
      // Initialize Firebase Remote Config
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values (fallback)
      await remoteConfig.setDefaults({
        'coda_api_token': '',
        'coda_doc_id': '',
        'coda_table_id': '',
      });

      // Configure settings
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Fetch and activate remote config
      await remoteConfig.fetchAndActivate();

      // Get values from Remote Config
      _apiToken = remoteConfig.getString('coda_api_token');
      _docId = remoteConfig.getString('coda_doc_id');
      _tableId = remoteConfig.getString('coda_table_id');

      // If Remote Config values are empty, try SharedPreferences as fallback
      if (!isConfigured) {
        await _loadFromSharedPreferences();
      } else {
        // Save successful Remote Config values to SharedPreferences as backup
        await _saveToSharedPreferences();
      }
    } catch (e) {
      // If Firebase Remote Config fails, fall back to SharedPreferences
      await _loadFromSharedPreferences();
    }
  }

  /// Fallback method to load from SharedPreferences
  static Future<void> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('coda_api_token');
    final savedDocId = prefs.getString('coda_doc_id');
    final savedTableId = prefs.getString('coda_table_id');

    if (savedToken != null && savedToken.isNotEmpty) _apiToken = savedToken;
    if (savedDocId != null && savedDocId.isNotEmpty) _docId = savedDocId;
    if (savedTableId != null && savedTableId.isNotEmpty) _tableId = savedTableId;
  }

  /// Save current configuration to SharedPreferences as backup
  static Future<void> _saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coda_api_token', _apiToken);
    await prefs.setString('coda_doc_id', _docId);
    await prefs.setString('coda_table_id', _tableId);
  }

  /// Update configuration (usually called from settings screen)
  static Future<void> updateConfig({
    required String apiToken,
    required String docId,
    required String tableId,
  }) async {
    _apiToken = apiToken;
    _docId = docId;
    _tableId = tableId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coda_api_token', apiToken);
    await prefs.setString('coda_doc_id', docId);
    await prefs.setString('coda_table_id', tableId);
  }
}
