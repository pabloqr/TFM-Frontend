import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _baseUrlKey = 'backend_base_url';
  static const String defaultBaseUrl = 'http://100.70.62.176:3000';

  final SharedPreferences _sharedPreferences;

  String _currentBaseUrl = defaultBaseUrl;

  SettingsProvider({required SharedPreferences sharedPreferences}) : _sharedPreferences = sharedPreferences;

  String get currentBaseUrl => _currentBaseUrl;

  Future<void> initialize() async {
    _currentBaseUrl = _sharedPreferences.getString(_baseUrlKey) ?? defaultBaseUrl;
    notifyListeners();
  }

  Future<void> updateBaseUrl(String newUrl) async {
    if (newUrl.isEmpty) return;

    if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
      return;
    }

    await _sharedPreferences.setString(_baseUrlKey, newUrl);
    _currentBaseUrl = newUrl;
    notifyListeners();
  }
}
