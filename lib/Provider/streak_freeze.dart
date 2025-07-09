import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakFreezeProvider with ChangeNotifier {
  static final StreakFreezeProvider _instance =
      StreakFreezeProvider._internal();
  factory StreakFreezeProvider() => _instance;

  StreakFreezeProvider._internal() {
    _loadFromPrefs();
    _listenToCloud();
  }

  static const _key = 'streak_freeze_count';

  int _freezeCount = 0;
  int get freezeCount => _freezeCount;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _freezeCount = prefs.getInt(_key) ?? 0;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _freezeCount);
  }

  Future<void> _saveToCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'streakFreezes': _freezeCount,
    }, SetOptions(merge: true));
  }

  void _listenToCloud() {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null || user!.isAnonymous) {
      debugPrint(
        "⚠️ [StreakFreezeProvider] Listener skipped — UID null or anonymous.",
      );
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (doc) async {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null || currentUser.isAnonymous) {
              debugPrint(
                "⛔ [StreakFreezeProvider] User signed out — skipping snapshot.",
              );
              return;
            }

            final data = doc.data();
            final cloudValue = data?['streakFreezes'];

            if (cloudValue is int && cloudValue != _freezeCount) {
              _freezeCount = cloudValue;
              await _saveToPrefs();
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint(
              "🔥 [StreakFreezeProvider] Firestore listener error: $error",
            );
          },
          cancelOnError: true,
        );
  }

  Future<void> cancelListener() async {
    await _subscription?.cancel();
    _subscription = null;
    debugPrint("🛑 StreakFreezeProvider listener cancelled.");
  }

  @override
  void dispose() {
    cancelListener();
    super.dispose();
  }

  Future<void> addFreeze([int count = 1]) async {
    _freezeCount += count;
    await _saveToPrefs();
    await _saveToCloud();
    notifyListeners();
  }

  Future<bool> useFreeze() async {
    if (_freezeCount > 0) {
      _freezeCount--;
      await _saveToPrefs();
      await _saveToCloud();
      notifyListeners();
      return true;
    }
    return false;
  }
}
