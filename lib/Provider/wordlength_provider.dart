import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WordLengthProvider with ChangeNotifier {
  int _wordLength = 5;
  int get wordLength => _wordLength;

  StreamSubscription<DocumentSnapshot>? _subscription;

  WordLengthProvider() {
    _loadFromPrefs();
    _listenToCloud();
  }

  /// Load word length from SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _wordLength = prefs.getInt('menu_wordLength') ?? 5;
    notifyListeners();
  }

  /// Update word length and save to local and cloud
  void setWordLength(int length) async {
    _wordLength = length;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('menu_wordLength', length);

    await _saveToCloud(length);
  }

  /// Save to Firestore
  Future<void> _saveToCloud(int length) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'menuWordLength': length,
    }, SetOptions(merge: true));
  }

  /// Listen to Firestore updates
  void _listenToCloud() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
          final cloudValue = doc.data()?['menuWordLength'];
          if (cloudValue is int && cloudValue != _wordLength) {
            _wordLength = cloudValue;

            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('menu_wordLength', _wordLength);

            notifyListeners();
          }
        });
  }

  /// Cancel Firestore listener
  void cancelListener() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Dispose to clean up the listener
  void dispose() {
    cancelListener();
    super.dispose();
  }
}
