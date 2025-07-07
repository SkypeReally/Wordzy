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

  Future<void> markPlayed(DateTime date, int wordLength) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(date, wordLength);
    await prefs.setBool(key, true);

    await uploadToFirestore();
  }

  Future<bool> isPlayed(DateTime date, int wordLength) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(date, wordLength);
    return prefs.getBool(key) ?? false;
  }

  static Future<bool> hasPlayedToday(int wordLength) async {
    final tracker = DailyWordPlayedTracker();
    final today = DateTime.now();
    return await tracker.isPlayed(today, wordLength);
  }

  String _generateKey(DateTime date, int wordLength) {
    final dateStr =
        "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
    return 'daily_played_${wordLength}_$dateStr';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

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

  Future<void> uploadToFirestore() async {
    if (_uid == null) return;

    final playedMap = await getAllPlayedStatus();
    await _firestore.collection('users').doc(_uid).set({
      'dailyWordPlayed': playedMap,
    }, SetOptions(merge: true));
  }

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

  void listenToDailyPlayed() {
    final uid = _uid;
    print("🧪 [DailyWordPlayedTracker] listenToDailyPlayed()");
    print("🧪 UID: $uid");

    if (uid == null) {
      print("⚠️ UID is null — DailyWord listener not started.");
      return;
    }

    _listener?.cancel();
    print("🔁 Starting Firestore listener for dailyWordPlayed...");

    _listener = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (doc) async {
            print("📥 Received Firestore snapshot for dailyWordPlayed");

            final cloudMap = doc.data()?['dailyWordPlayed'];
            print("📦 dailyWordPlayed data: $cloudMap");

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
                    print("✅ Synced local key: $key");
                  } else {
                    print(
                      "⚠️ Could not parse wordLength from key: ${entry.key}",
                    );
                  }
                } else {
                  print("⚠️ Invalid key format in Firestore: ${entry.key}");
                }
              }
            } else {
              print("⚠️ dailyWordPlayed field missing or not a map.");
            }
          },
          onError: (error) {
            print(
              "🔥 Firestore listener error in DailyWordPlayedTracker: $error",
            );
          },
        );
  }

  void cancelListener() {
    _listener?.cancel();
    _listener = null;
  }
}
