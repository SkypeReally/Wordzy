import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class WordListService {
  static final Map<int, List<String>> _wordLists = {}; // General words
  static final Map<String, Map<int, List<String>>> _categoryWordLists =
      {}; // Category → Length → Words
  static bool _loaded = false;

  /// Loads general and category word lists from separate JSON files
  static Future<void> loadWordList() async {
    if (_loaded) return;

    // 🔤 Load general word list
    final String generalJson = await rootBundle.loadString(
      'assets/word_list.json',
    );
    final Map<String, dynamic> generalData = json.decode(generalJson);

    for (final key in generalData.keys) {
      final int length = int.tryParse(key) ?? 0;
      if (length > 0 && generalData[key] is List) {
        final words = List<String>.from(generalData[key])
            .map((w) => w.trim().toUpperCase())
            .where((w) => w.length == length)
            .toList();
        _wordLists[length] = words;
      }
    }

    // 🧩 Load category word list
    final String categoryJson = await rootBundle.loadString(
      'assets/category_words.json',
    );
    final Map<String, dynamic> categoryData = json.decode(categoryJson);

    for (final categoryKey in categoryData.keys) {
      final categoryValue = categoryData[categoryKey];
      final Map<int, List<String>> lengthMap = {};

      if (categoryValue is Map<String, dynamic>) {
        for (final lenKey in categoryValue.keys) {
          final int length = int.tryParse(lenKey) ?? 0;
          if (length == 0) continue;

          final words = List<String>.from(categoryValue[lenKey])
              .map((w) => w.trim().toUpperCase())
              .where((w) => w.length == length)
              .toList();

          if (words.isNotEmpty) {
            lengthMap[length] = words;
          }
        }
      }

      _categoryWordLists[categoryKey.toLowerCase()] = lengthMap;
    }

    _loaded = true;
  }

  /// 🔤 Returns a random general word of a specific length.
  static Future<String> getRandomWord(int length) async {
    await loadWordList();
    final list = _wordLists[length] ?? [];
    return list.isEmpty ? '' : list[Random().nextInt(list.length)];
  }

  /// 📆 Returns a deterministic daily word of specific length.
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

  /// 🎲 Returns a random word from a given category of a specific length range.
  static Future<String> getRandomWordFromCategory(
    String category,
    int minLength,
    int maxLength,
    Set<String> alreadyFoundWords,
  ) async {
    await loadWordList();
    final categoryData = _categoryWordLists[category.toLowerCase()];
    if (categoryData == null) {
      throw Exception('No words found for category "$category"');
    }

    final allWords = categoryData.entries
        .where((e) => e.key >= minLength && e.key <= maxLength)
        .expand((e) => e.value)
        .toSet();

    final available = allWords
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

  /// 🎲 Returns a random word from a category of any length.
  static Future<String> getRandomWordFromCategoryAnyLength(
    String category,
  ) async {
    await loadWordList();
    final categoryData = _categoryWordLists[category.toLowerCase()];
    if (categoryData == null || categoryData.isEmpty) {
      throw Exception('No words found in category "$category"');
    }

    final allWords = categoryData.values.expand((list) => list).toList();
    return allWords[Random().nextInt(allWords.length)];
  }

  /// 📋 Returns general words of a given length.
  static List<String> getListForLength(int length) {
    return _wordLists[length] ?? [];
  }

  /// 🧠 Returns all available categories.
  static List<String> getAvailableCategories() {
    return _categoryWordLists.keys.toList()..sort();
  }

  /// 📚 Returns all words in a category regardless of length.
  static List<String> getWordsFromCategory(String category) {
    return _categoryWordLists[category.toLowerCase()]?.values
            .expand((list) => list)
            .toList() ??
        [];
  }

  /// 📏 Returns available word lengths in a category.
  static List<int> getAvailableLengthsForCategory(String category) {
    return _categoryWordLists[category.toLowerCase()]?.keys.toList() ?? [];
  }

  /// 📐 Returns words of a specific length in a category.
  static List<String> getCategoryWords(String category, int length) {
    return _categoryWordLists[category.toLowerCase()]?[length] ?? [];
  }
}
