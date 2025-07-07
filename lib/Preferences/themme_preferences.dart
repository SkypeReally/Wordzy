import 'package:shared_preferences/shared_preferences.dart';

class ThemePreference {
  static const String _key = 'isDarkTheme';

  /// Saves the selected theme preference (true = dark, false = light).
  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }

  /// Returns the saved theme preference. Defaults to `false` (light) if not set.
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}
