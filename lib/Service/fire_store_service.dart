import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SetOptions _mergeOptions = SetOptions(merge: true);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Uploads all game data (stats, settings, daily word progress) to Firestore
  Future<void> uploadAllGameData({
    required Map<String, dynamic> stats,
    required Map<String, dynamic> settings,
    required Map<String, dynamic> dailyWordPlayed,
  }) async {
    if (_uid == null) {
      print("❌ Cannot upload: UID is null.");
      return;
    }

    final data = {
      'stats': stats,
      'settings': settings,
      'dailyWordPlayed': dailyWordPlayed,
    };

    await _db.collection('users').doc(_uid).set(data, _mergeOptions);
  }

  /// Loads general stats from Firestore
  Future<Map<String, dynamic>?> loadStats() async {
    if (_uid == null) return null;

    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data();

    if (data == null || data['stats'] == null) return null;

    return Map<String, dynamic>.from(data['stats']);
  }

  /// Loads settings from Firestore
  Future<Map<String, dynamic>?> loadSettings() async {
    if (_uid == null) return null;

    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data();

    if (data == null || data['settings'] == null) return null;

    return Map<String, dynamic>.from(data['settings']);
  }

  /// Loads daily word played tracker from Firestore
  Future<Map<String, dynamic>> loadDailyWordPlayed() async {
    if (_uid == null) return {};

    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data();

    if (data == null || data['dailyWordPlayed'] == null) return {};

    return Map<String, dynamic>.from(data['dailyWordPlayed']);
  }

  /// Saves the `dailyWordPlayed` map to Firestore
  Future<void> saveDailyWordPlayed(Map<String, bool> playedMap) async {
    if (_uid == null) return;

    await _db.collection('users').doc(_uid).set({
      'dailyWordPlayed': playedMap,
    }, _mergeOptions);
  }

  /// Saves the settings map to Firestore
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    if (_uid == null) return;

    await _db.collection('users').doc(_uid).set({
      'settings': settings,
    }, _mergeOptions);
  }
}
