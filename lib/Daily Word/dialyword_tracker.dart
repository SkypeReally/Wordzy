import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyWordPlayedTracker {
  static final DailyWordPlayedTracker _instance =
      DailyWordPlayedTracker._internal();
  factory DailyWordPlayedTracker() => _instance;
  DailyWordPlayedTracker._internal();

  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _listener;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  bool get _isAnonymous =>
      FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  /// 🔹 Mark word as played with result (win or loss)
  Future<void> markPlayed(
    DateTime date,
    int wordLength, {
    required bool won,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(date, wordLength);
    await prefs.setString(key, won ? 'win' : 'loss');
    await uploadToFirestore(); // Skips if anonymous
  }

  /// 🔹 Check if played
  Future<bool> isPlayed(DateTime date, int wordLength) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(date, wordLength);
    return prefs.containsKey(key);
  }

  /// 🔹 Check today's status (bool only)
  static Future<bool> hasPlayedToday(int wordLength) async {
    return await DailyWordPlayedTracker().isPlayed(DateTime.now(), wordLength);
  }

  /// 🔹 Get outcome: 'win', 'loss', or null
  static Future<String?> getOutcomeToday(int wordLength) async {
    final prefs = await SharedPreferences.getInstance();
    final key = DailyWordPlayedTracker()._generateKey(
      DateTime.now(),
      wordLength,
    );
    return prefs.getString(key);
  }

  /// 🔹 Format: daily_played_5_2025-07-07
  String _generateKey(DateTime date, int wordLength) {
    final dateStr =
        "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
    return 'daily_played_${wordLength}_$dateStr';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 🔹 Get all played outcomes: { '2025-07-15_5': 'win', ... }
  Future<Map<String, String>> getAllPlayedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final played = <String, String>{}; // ✅ Map holds 'win' or 'loss'

    for (final key in keys) {
      if (key.startsWith('daily_played_')) {
        final parts = key.split('_');
        if (parts.length == 4) {
          final wordLength = parts[2];
          final date = parts[3];

          final rawValue = prefs.get(key);
          if (rawValue is String && (rawValue == 'win' || rawValue == 'loss')) {
            final firestoreKey = '${date}_$wordLength';
            played[firestoreKey] = rawValue;
          } else {
            // Clean up old invalid values (optional, for safety)
            await prefs.remove(key);
          }
        }
      }
    }

    return played;
  }

  /// 🔹 Upload local outcomes to Firestore
  Future<void> uploadToFirestore() async {
    if (_uid == null || _isAnonymous) return;

    final playedMap = await getAllPlayedStatus();

    await _firestore.collection('users').doc(_uid).set({
      'dailyWordPlayed': playedMap,
    }, SetOptions(merge: true));
  }

  /// 🔹 Sync Firestore → local (for both win/loss)
  Future<void> syncFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final cloudMap = doc.data()?['dailyWordPlayed'];
    if (cloudMap == null || cloudMap is! Map) return;

    final prefs = await SharedPreferences.getInstance();
    for (final entry in cloudMap.entries) {
      final parts = entry.key.split('_');
      if (parts.length == 2 &&
          (entry.value == 'win' || entry.value == 'loss')) {
        final dateStr = parts[0];
        final wordLength = int.tryParse(parts[1]);
        if (wordLength != null) {
          final key = 'daily_played_${wordLength}_$dateStr';
          await prefs.setString(key, entry.value);
        }
      }
    }
  }

  /// 🔁 Real-time Firestore listener
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
                if (entry.value != 'win' && entry.value != 'loss') continue;

                final parts = entry.key.split('_');
                if (parts.length == 2) {
                  final dateStr = parts[0];
                  final wordLength = int.tryParse(parts[1]);
                  if (wordLength != null) {
                    final key = 'daily_played_${wordLength}_$dateStr';
                    await prefs.setString(key, entry.value);
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

  /// ❌ Cancel listener
  void cancelListener() {
    _listener?.cancel();
    _listener = null;
  }

  void dispose() {
    cancelListener();
  }
}
