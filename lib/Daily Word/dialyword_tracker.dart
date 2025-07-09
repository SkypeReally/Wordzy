import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyWordPlayedTracker {
  // ✅ Singleton
  static final DailyWordPlayedTracker _instance =
      DailyWordPlayedTracker._internal();
  factory DailyWordPlayedTracker() => _instance;
  DailyWordPlayedTracker._internal();

  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _listener;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  bool get _isAnonymous =>
      FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  /// 🔹 Mark word as played for a given date/length
  Future<void> markPlayed(DateTime date, int wordLength) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(date, wordLength);
    await prefs.setBool(key, true);
    await uploadToFirestore(); // Will be skipped if anonymous
  }

  /// 🔹 Check if word is played
  Future<bool> isPlayed(DateTime date, int wordLength) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(date, wordLength);
    return prefs.getBool(key) ?? false;
  }

  /// 🔹 Check today's status
  static Future<bool> hasPlayedToday(int wordLength) async {
    return await DailyWordPlayedTracker().isPlayed(DateTime.now(), wordLength);
  }

  /// 🔹 Format: daily_played_5_2025-07-07
  String _generateKey(DateTime date, int wordLength) {
    final dateStr =
        "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
    return 'daily_played_${wordLength}_$dateStr';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 🔹 Extract all local played keys
  Future<Map<String, bool>> getAllPlayedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final played = <String, bool>{};

    for (final key in keys) {
      if (key.startsWith('daily_played_')) {
        final parts = key.split('_');
        if (parts.length == 4) {
          final wordLength = parts[2];
          final date = parts[3];
          final firestoreKey = '${date}_$wordLength';
          if (prefs.getBool(key) == true) {
            played[firestoreKey] = true;
          }
        }
      }
    }

    return played;
  }

  /// 🔹 Upload local to Firestore
  Future<void> uploadToFirestore() async {
    if (_uid == null || _isAnonymous) return;

    final playedMap = await getAllPlayedStatus();

    await _firestore.collection('users').doc(_uid).set({
      'dailyWordPlayed': playedMap,
    }, SetOptions(merge: true));
  }

  /// 🔹 Sync Firestore → local
  Future<void> syncFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final cloudMap = doc.data()?['dailyWordPlayed'];
    if (cloudMap == null || cloudMap is! Map) return;

    final prefs = await SharedPreferences.getInstance();
    for (final entry in cloudMap.entries) {
      if (entry.value != true) continue;

      final parts = entry.key.split('_');
      if (parts.length == 2) {
        final dateStr = parts[0];
        final wordLength = int.tryParse(parts[1]);
        if (wordLength != null) {
          final key = 'daily_played_${wordLength}_$dateStr';
          await prefs.setBool(key, true);
        }
      }
    }
  }

  /// 🔁 Real-time sync
  void listenToDailyPlayed() {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final isAnonymous = user?.isAnonymous ?? true;

    if (uid == null || isAnonymous) return;

    _listener?.cancel();

    _listener = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (doc) async {
            final cloudMap = doc.data()?['dailyWordPlayed'];
            if (cloudMap is Map) {
              final prefs = await SharedPreferences.getInstance();
              for (final entry in cloudMap.entries) {
                if (entry.value != true) continue;

                final parts = entry.key.split('_');
                if (parts.length == 2) {
                  final dateStr = parts[0];
                  final wordLength = int.tryParse(parts[1]);
                  if (wordLength != null) {
                    final key = 'daily_played_${wordLength}_$dateStr';
                    await prefs.setBool(key, true);
                  }
                }
              }
            }
          },
          onError: (error) {
            print(
              "🔥 Firestore listener error in DailyWordPlayedTracker: $error",
            );
          },
        );
  }

  /// ❌ Cancel sync
  void cancelListener() {
    _listener?.cancel();
    _listener = null;
  }

  void dispose() {
    cancelListener();
  }
}
