import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Service/wordlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProgressProvider extends ChangeNotifier {
  final Map<String, Set<String>> _foundWordsPerCategory = {};
  late SharedPreferences _prefs;
  static const String _storageKey = 'category_progress_local';
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    _loadFromLocal();

    await _mergeFromFirestore();
    _saveToLocal();

    _initialized = true;
    notifyListeners();
  }

  Future<void> _mergeFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()?['category_progress'] != null) {
        final cloudData = doc['category_progress'] as Map<String, dynamic>;

        cloudData.forEach((category, wordList) {
          final cat = category.toLowerCase();
          final localSet = _foundWordsPerCategory.putIfAbsent(
            cat,
            () => <String>{},
          );
          for (final word in List<String>.from(wordList)) {
            localSet.add(word.trim().toUpperCase());
          }
        });
      }

      await _saveToFirestore();
    } catch (e) {
      debugPrint('❌ Error loading category progress from Firestore: $e');
    }
  }

  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final Map<String, List<String>> toSave = {};
      _foundWordsPerCategory.forEach((key, value) {
        toSave[key] = value.toList();
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'category_progress': toSave,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error saving category progress to Firestore: $e');
    }
  }

  void _loadFromLocal() {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null) return;

    try {
      final decoded = json.decode(rawJson) as Map<String, dynamic>;
      decoded.forEach((category, words) {
        final cat = category.toLowerCase();
        _foundWordsPerCategory[cat] = Set<String>.from(
          words.map((w) => w.toString().toUpperCase()),
        );
      });
    } catch (e) {
      debugPrint('❌ Error decoding local category progress: $e');
    }
  }

  void _saveToLocal() {
    final Map<String, List<String>> toSave = {};
    _foundWordsPerCategory.forEach((key, value) {
      toSave[key] = value.toList();
    });
    _prefs.setString(_storageKey, json.encode(toSave));
  }

  Future<void> resetLocalOnly() async {
    _foundWordsPerCategory.clear();
    await _prefs.remove(_storageKey);
    _initialized = false;
    notifyListeners();
  }

  Future<void> resetAll() async {
    _foundWordsPerCategory.clear();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'category_progress': {}},
      );
    }
    await _prefs.remove(_storageKey);
    notifyListeners();
  }

  int getFoundCount(String category) {
    return _foundWordsPerCategory[category.toLowerCase()]?.length ?? 0;
  }

  String getBadge(String category) {
    final count = getFoundCount(category);
    if (count >= 100) return "💎 Diamond";
    if (count >= 60) return "🥇 Gold";
    if (count >= 25) return "🥈 Silver";
    if (count >= 10) return "🥉 Bronze";
    return "🔘 None";
  }

  double getCategoryProgress(String category) {
    final foundWords = getFoundWords(category);
    final totalWords = WordListService.getWordsFromCategory(category).length;
    if (totalWords == 0) return 0.0;
    return foundWords.length / totalWords;
  }

  Future<void> markWordFound(String category, String word) async {
    final cat = category.toLowerCase();
    final normalized = word.trim().toUpperCase();

    _foundWordsPerCategory.putIfAbsent(cat, () => <String>{});
    final added = _foundWordsPerCategory[cat]!.add(normalized);

    if (added) {
      _saveToLocal();
      await _saveToFirestore();
      notifyListeners();
    }
  }

  Future<bool> markWordFoundAndCheckBadge(String category, String word) async {
    final oldBadge = getBadge(category);
    await markWordFound(category, word);
    final newBadge = getBadge(category);
    return oldBadge != newBadge;
  }

  Set<String> getFoundWords(String category) {
    return _foundWordsPerCategory[category.toLowerCase()] ?? {};
  }

  bool isWordAlreadyFound(String category, String word) {
    return _foundWordsPerCategory[category.toLowerCase()]?.contains(
          word.trim().toUpperCase(),
        ) ??
        false;
  }
}
