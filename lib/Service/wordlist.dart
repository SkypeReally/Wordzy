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
          final categoryValue = categoryData[categoryKey];
          final List<String> flatWords = [];

          if (categoryValue is Map<String, dynamic>) {
            for (var lenKey in categoryValue.keys) {
              final words = List<String>.from(categoryValue[lenKey])
                  .map((w) => w.trim().toUpperCase())
                  .where((w) => w.isNotEmpty)
                  .toList();
              flatWords.addAll(words);
            }
          } else if (categoryValue is List) {
            // Legacy support: flat list
            flatWords.addAll(
              categoryValue
                  .map((w) => w.toString().trim().toUpperCase())
                  .where((w) => w.isNotEmpty),
            );
          }

          _categoryWordLists[categoryKey.toLowerCase()] = flatWords;
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

  /// Returns a random general word of a specific length.
  static Future<String> getRandomWord(int length) async {
    await loadWordList();
    final list = _wordLists[length] ?? [];
    if (list.isEmpty) return '';
    return list[Random().nextInt(list.length)];
  }

  /// Returns a deterministic daily word of specific length.
  static Future<String> getDailyWord(int length) async {
    await loadWordList();
    final list = _wordLists[length] ?? [];

    debugPrint(
      "📘 DailyWordService: Loaded list for length $length → ${list.length} words",
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

  /// Returns a random word from a given category of a specific length range.
  static Future<String> getRandomWordFromCategory(
    String category,
    int minLength,
    int maxLength,
    Set<String> alreadyFoundWords,
  ) async {
    await loadWordList();

    final words = _categoryWordLists[category.toLowerCase()];
    if (words == null || words.isEmpty) {
      throw Exception('No words found for category "$category"');
    }

    // Filter by length
    final lengthFiltered = words
        .where((w) => w.length >= minLength && w.length <= maxLength)
        .toSet();

    // Exclude already found words
    final available = lengthFiltered
        .difference(
          alreadyFoundWords.map((w) => w.trim().toUpperCase()).toSet(),
        )
        .toList();

    if (available.isEmpty) {
      throw Exception(
        '🎉 All words found or none available for category "$category"',
      );
    }

    available.shuffle();
    return available.first;
  }

  /// Returns a random word from a category of any length.
  static Future<String> getRandomWordFromCategoryAnyLength(
    String category,
  ) async {
    await loadWordList();

    final words = _categoryWordLists[category.toLowerCase()];
    if (words == null || words.isEmpty) {
      throw Exception('No words found in category "$category"');
    }

    return words[Random().nextInt(words.length)];
  }

  /// Returns all available general words for a given length.
  static List<String> getListForLength(int length) {
    return _wordLists[length] ?? [];
  }

  /// Returns all available categories (in lowercase).
  static List<String> getAvailableCategories() {
    return _categoryWordLists.keys.toList()..sort();
  }

  /// Returns all words in a category (regardless of length).
  static List<String> getWordsFromCategory(String category) {
    return _categoryWordLists[category.toLowerCase()] ?? [];
  }

  /// Returns all distinct word lengths available in a category.
  static List<int> getAvailableLengthsForCategory(String category) {
    final words = _categoryWordLists[category.toLowerCase()] ?? [];
    return words.map((w) => w.length).toSet().toList()..sort();
  }

  /// ✅ NEW: Returns words of a specific length in a category.
  static List<String> getCategoryWords(String category, int length) {
    final words = _categoryWordLists[category.toLowerCase()] ?? [];
    return words.where((w) => w.length == length).toList();
  }
}
