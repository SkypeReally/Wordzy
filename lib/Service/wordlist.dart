import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class WordListService {
  static final Map<int, List<String>> _wordLists = {};
  static final Map<String, List<String>> _categoryWordLists = {};
  static bool _loaded = false;

  /// Loads the word list and category data from assets and caches it.
  static Future<void> loadWordList() async {
    if (_loaded) return;

    final String jsonString = await rootBundle.loadString(
      'assets/word_list.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    for (var key in jsonData.keys) {
      if (key == "categories" && jsonData[key] is Map) {
        final Map<String, dynamic> categoryData = jsonData[key];
        for (var categoryKey in categoryData.keys) {
          final words = List<String>.from(categoryData[categoryKey])
              .map((w) => w.trim().toUpperCase())
              .where((w) => w.isNotEmpty)
              .toList();
          _categoryWordLists[categoryKey.toLowerCase()] = words;
        }
      } else {
        final int length = int.tryParse(key) ?? 0;
        if (length > 0 && jsonData[key] is List) {
          final words = List<String>.from(jsonData[key])
              .map((w) => w.trim().toUpperCase())
              .where((w) => w.isNotEmpty)
              .toList();
          _wordLists[length] = words;
        }
      }
    }

    _loaded = true;
  }

  /// Returns a random word for the given length (non-daily, general mode).
  static Future<String> getRandomWord(int length) async {
    await loadWordList();
    final list = _wordLists[length] ?? [];
    if (list.isEmpty) return '';
    return list[Random().nextInt(list.length)];
  }

  /// Returns a deterministic daily word based on the current date.
  static Future<String> getDailyWord(int length) async {
    await loadWordList();
    final list = _wordLists[length] ?? [];

    debugPrint(
      "📘 DailyWordService: loaded list for length $length → ${list.length} words",
    );

    if (list.isEmpty) {
      debugPrint("❌ DailyWordService: No words found for length $length");
      return '';
    }

    final today = DateTime.now();
    final seed = int.parse(
      "${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}",
    );

    final rng = Random(seed);
    final word = list[rng.nextInt(list.length)];

    debugPrint("✅ DailyWordService: Selected word → $word");

    return word;
  }

  /// Returns a random word from a given category and word length.
  static Future<String> getRandomWordFromCategory(
    String category,
    int length,
  ) async {
    await loadWordList();

    final words = _categoryWordLists[category.toLowerCase()];
    if (words == null || words.isEmpty) {
      throw Exception('No words found for category "$category"');
    }

    final filtered = words.where((w) => w.length == length).toList();
    if (filtered.isEmpty) {
      throw Exception(
        'No words of length $length found in category "$category"',
      );
    }

    return filtered[Random().nextInt(filtered.length)];
  }

  /// Returns all words for a given length.
  static List<String> getListForLength(int length) {
    return _wordLists[length] ?? [];
  }

  /// Returns all available categories (as lowercase names).
  static List<String> getAvailableCategories() {
    return _categoryWordLists.keys.toList();
  }

  /// Returns all words in a category (no filtering by length).
  static List<String> getWordsFromCategory(String category) {
    return _categoryWordLists[category.toLowerCase()] ?? [];
  }
}
