import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class DailyWordService {
  static Map<int, List<String>> _wordMap = {};
  static bool _isLoaded = false;

  /// Loads daily words from assets/word_list.json.
  /// This is called once and cached.
  static Future<void> loadDailyWords() async {
    if (_isLoaded) return;

    try {
      final data = await rootBundle.loadString('assets/word_list.json');
      final Map<String, dynamic> json = jsonDecode(data);

      _wordMap = {
        for (var entry in json.entries)
          if (int.tryParse(entry.key) != null)
            int.parse(entry.key): List<String>.from(entry.value),
      };

      _isLoaded = true;
      print("✅ Daily words loaded successfully.");
    } catch (e) {
      print("❌ Failed to load daily words: $e");
      _isLoaded = false;
    }
  }

  /// Returns the daily word for a given length and date
  static String getDailyWord(int wordLength, DateTime date) {
    final words = _wordMap[wordLength] ?? [];
    if (words.isEmpty) {
      print("⚠️ No words found for length $wordLength");

      return '';
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final key = "$formattedDate-$wordLength";

    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    final index =
        digest.bytes.sublist(0, 4).fold(0, (a, b) => a * 256 + b) %
        words.length;

    return words[index].toUpperCase();
  }
}
