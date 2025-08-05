import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DebugUtils {
  static Future<void> clearDailyWordPlayedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (int length = 3; length <= 8; length++) {
      final key = 'daily_played_${length}_$today';
      await prefs.remove(key);
      print('🧹 Cleared: $key');
    }
  }
}
