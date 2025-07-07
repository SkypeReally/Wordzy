import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DebugUtils {
  /// Clears today's daily word "played" state for all word lengths (3–8)
  static Future<void> clearDailyWordPlayedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (int length = 3; length <= 8; length++) {
      final key = 'daily_played_${length}_$today';
      await prefs.remove(key);
      // Optional: print for debug
      print('🧹 Cleared: $key');
    }
  }
}
