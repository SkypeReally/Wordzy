import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProgressProvider extends ChangeNotifier {
  final Map<String, Set<String>> _foundWordsPerCategory = {};
  late SharedPreferences _prefs;

  static const String _storageKey = 'category_progress';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson != null) {
      final Map<String, dynamic> decoded = json.decode(rawJson);
      decoded.forEach((category, words) {
        _foundWordsPerCategory[category] = Set<String>.from(words);
      });
    }

    _initialized = true;
  }

  /// Returns the number of words found in a category.
  int getFoundCount(String category) {
    return _foundWordsPerCategory[category.toLowerCase()]?.length ?? 0;
  }

  /// Returns the badge level based on number of words found.
  String getBadge(String category) {
    final count = getFoundCount(category);
    if (count >= 100) return "💎 Diamond";
    if (count >= 60) return "🥇 Gold";
    if (count >= 25) return "🥈 Silver";
    if (count >= 10) return "🥉 Bronze";
    return "🔘 None";
  }

  /// Adds a word to the category's found set.
  Future<void> markWordFound(String category, String word) async {
    final cat = category.toLowerCase();
    final normalized = word.trim().toUpperCase();

    _foundWordsPerCategory.putIfAbsent(cat, () => <String>{});
    final added = _foundWordsPerCategory[cat]!.add(normalized);

    if (added) {
      await _save();
      notifyListeners();
    }
  }

  /// Returns a list of all words found in a category.
  Set<String> getFoundWords(String category) {
    return _foundWordsPerCategory[category.toLowerCase()] ?? {};
  }

  /// Checks whether a word is already found.
  bool isWordAlreadyFound(String category, String word) {
    return _foundWordsPerCategory[category.toLowerCase()]?.contains(
          word.trim().toUpperCase(),
        ) ??
        false;
  }

  /// Clears all progress (for debug or reset).
  Future<void> resetAll() async {
    _foundWordsPerCategory.clear();
    await _prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> _save() async {
    final Map<String, List<String>> toSave = {};
    _foundWordsPerCategory.forEach((key, value) {
      toSave[key] = value.toList();
    });

    await _prefs.setString(_storageKey, json.encode(toSave));
  }
}
