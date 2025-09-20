import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordLengthProvider with ChangeNotifier {
  int? _wordLength;
  bool _isInitialized = false;

  StreamSubscription<DocumentSnapshot>? _subscription;

  int get wordLength {
    if (!_isInitialized) {
      throw Exception("WordLengthProvider not initialized yet");
    }
    return _wordLength!;
  }

  bool get isInitialized => _isInitialized;

  WordLengthProvider();

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    int? localLength = prefs.getInt('menuWordLength');

    if (localLength != null) {
      _wordLength = localLength;
      debugPrint("🟢 [WordLengthProvider] Loaded from prefs: $localLength");
    } else {
      _wordLength = 5;
      debugPrint("🟡 [WordLengthProvider] No prefs found, using default: 5");
    }

    _isInitialized = true;
    notifyListeners();

    _listenToCloud();
  }

  void setWordLength(int length) async {
    if (!_isInitialized) {
      debugPrint("⚠️ [WordLengthProvider] setWordLength called before init");
      return;
    }
    if (_wordLength == length) return;

    _wordLength = length;
    debugPrint("🔁 [WordLengthProvider] Word length updated: $length");
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('menuWordLength', length);

    await _saveToCloud(length);
  }

  Future<void> _saveToCloud(int length) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'menuWordLength': length,
      }, SetOptions(merge: true));
      debugPrint("✅ [WordLengthProvider] Saved to Firestore: $length");
    } catch (e) {
      debugPrint("🔥 [WordLengthProvider] Error saving to cloud: $e");
    }
  }

  void _listenToCloud() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      debugPrint(
        "⚠️ [WordLengthProvider] No signed-in user. Skipping Firestore listener.",
      );
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (doc) async {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null || currentUser.isAnonymous) {
              debugPrint(
                "🚫 [WordLengthProvider] User signed out – ignoring Firestore update.",
              );
              return;
            }

            final cloudValue = doc.data()?['menuWordLength'];
            if (cloudValue is int && cloudValue != _wordLength) {
              debugPrint(
                "☁️ [WordLengthProvider] Cloud updated value: $cloudValue",
              );

              _wordLength = cloudValue;
              notifyListeners();

              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('menuWordLength', cloudValue);
            }
          },
          onError: (error) {
            debugPrint(
              "🔥 [WordLengthProvider] Firestore listener error: $error",
            );
          },
          cancelOnError: true,
        );
  }

  void cancelListener() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    cancelListener();
    super.dispose();
  }
}
