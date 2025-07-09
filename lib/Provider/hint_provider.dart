import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HintsProvider extends ChangeNotifier {
  static const _prefsKey = 'hints_enabled';

  bool _isHintsEnabled = false;
  bool _hasUsedHint = false;

  bool get isHintsEnabled => _isHintsEnabled;
  bool get hasUsedHint => _hasUsedHint;

  /// Call this once on startup
  Future<void> loadHintsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isHintsEnabled = prefs.getBool(_prefsKey) ?? false;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final cloudValue = doc.data()?['settings']?['hintsEnabled'];
        if (cloudValue != null && cloudValue is bool) {
          _isHintsEnabled = cloudValue;
          await prefs.setBool(_prefsKey, _isHintsEnabled); // Sync local
        }
      } catch (e) {
        debugPrint("Error loading hints from Firestore: $e");
      }
    }

    notifyListeners();
  }

  Future<void> setHintsEnabled(bool enabled) async {
    _isHintsEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'settings': {'hintsEnabled': enabled},
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving hints to Firestore: $e");
      }
    }

    notifyListeners();
  }

  void consumeHint() {
    _hasUsedHint = true;
    notifyListeners();
  }

  void resetHintUsage() {
    _hasUsedHint = false;
    notifyListeners();
  }
}
