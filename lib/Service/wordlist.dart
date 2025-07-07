import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class WordListService {
  static final Map<int, List<String>> _wordLists = {};
  static bool _loaded = false;

  /// Loads the word list once from assets and caches it in `_wordLists`.
  static Future<void> loadWordList() async {
    if (_loaded) return;

    final String jsonString = await rootBundle.loadString(
      'assets/word_list.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    jsonData.forEach((key, value) {
      final int length = int.tryParse(key) ?? 0;
      if (length > 0 && value is List) {
        _wordLists[length] = List<String>.from(value)
            .map((w) => w.trim().toUpperCase())
            .where((w) => w.isNotEmpty)
            .toList();
      }
    });

    _loaded = true;
  }

  /// Returns a random word for the given length.
  static Future<String> getRandomWord(int length) async {
    await loadWordList();
    final list = _wordLists[length] ?? [];
    if (list.isEmpty) return '';
    final rng = Random();
    return list[rng.nextInt(list.length)];
  }

  /// Returns a daily deterministic word based on the current date.
  static Future<String> getDailyWord(int length) async {
    await loadWordList();
    final list = _wordLists[length] ?? [];
    if (list.isEmpty) return '';

    final today = DateTime.now();
    final seed = int.parse(
      "${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}",
    );

    final rng = Random(seed);
    return list[rng.nextInt(list.length)];
  }

  /// Returns the full list of words for a given length.
  static List<String> getListForLength(int length) {
    return _wordLists[length] ?? [];
  }
}
