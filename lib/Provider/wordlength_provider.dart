import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WordLengthProvider with ChangeNotifier {
  int _wordLength = 5;
  bool _isInitialized = false;

  int get wordLength => _wordLength;
  bool get isInitialized => _isInitialized;

  StreamSubscription<DocumentSnapshot>? _subscription;

  WordLengthProvider() {
    loadFromPrefs();
    _listenToCloud();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _wordLength = prefs.getInt('menu_wordLength') ?? 5;
    _isInitialized = true;
    notifyListeners();
  }

  void setWordLength(int length) async {
    _wordLength = length;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('menu_wordLength', length);

    await _saveToCloud(length);
  }

  Future<void> _saveToCloud(int length) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'menuWordLength': length,
    }, SetOptions(merge: true));
  }

  void _listenToCloud() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    final uid = user.uid;

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (doc) async {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null || currentUser.isAnonymous) {
              debugPrint(
                "🚫 [WordLengthProvider] User is signed out — skipping Firestore update.",
              );
              return;
            }

            final cloudValue = doc.data()?['menuWordLength'];
            if (cloudValue is int && cloudValue != _wordLength) {
              _wordLength = cloudValue;

              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('menu_wordLength', _wordLength);

              notifyListeners();
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

  void dispose() {
    cancelListener();
    super.dispose();
  }
}
