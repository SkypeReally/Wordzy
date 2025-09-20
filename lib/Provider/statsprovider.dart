import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsProvider with ChangeNotifier {
  //  General Stats
  int totalGamesPlayed = 0;
  int totalWins = 0;
  double winPercentage = 0.0;
  int currentStreak = 0;
  int _maxStreak = 0;
  List<int> guessDistribution = List.filled(6, 0);

  // Daily Stats
  int dailyGamesPlayed = 0;
  int dailyWins = 0;
  double dailyWinPercentage = 0.0;
  int dailyCurrentStreak = 0;
  int _dailyMaxStreak = 0;
  List<int> dailyGuessDistribution = List.filled(6, 0);

  StreamSubscription<DocumentSnapshot>? _statsSubscription;

  StatsProvider() {
    _loadStats();
  }

  int get maxStreak => _maxStreak;
  int get dailyMaxStreak => _dailyMaxStreak;

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    totalGamesPlayed = prefs.getInt('totalGames') ?? 0;
    totalWins = prefs.getInt('totalWins') ?? 0;
    currentStreak = prefs.getInt('currentStreak') ?? 0;
    _maxStreak = prefs.getInt('bestStreak') ?? 0;
    winPercentage = totalGamesPlayed > 0
        ? (totalWins / totalGamesPlayed) * 100
        : 0.0;
    for (int i = 0; i < 6; i++) {
      guessDistribution[i] = prefs.getInt('guessDist_$i') ?? 0;
    }

    dailyGamesPlayed = prefs.getInt('daily_totalGames') ?? 0;
    dailyWins = prefs.getInt('daily_totalWins') ?? 0;
    dailyCurrentStreak = prefs.getInt('daily_currentStreak') ?? 0;
    _dailyMaxStreak = prefs.getInt('daily_bestStreak') ?? 0;
    dailyWinPercentage = dailyGamesPlayed > 0
        ? (dailyWins / dailyGamesPlayed) * 100
        : 0.0;
    for (int i = 0; i < 6; i++) {
      dailyGuessDistribution[i] = prefs.getInt('daily_guessDist_$i') ?? 0;
    }

    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      listenToCloudStats();
    }
  }

  Future<void> saveStatsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalGames', totalGamesPlayed);
    await prefs.setInt('totalWins', totalWins);
    await prefs.setInt('currentStreak', currentStreak);
    await prefs.setInt('bestStreak', _maxStreak);
    for (int i = 0; i < 6; i++) {
      await prefs.setInt('guessDist_$i', guessDistribution[i]);
    }

    await prefs.setInt('daily_totalGames', dailyGamesPlayed);
    await prefs.setInt('daily_totalWins', dailyWins);
    await prefs.setInt('daily_currentStreak', dailyCurrentStreak);
    await prefs.setInt('daily_bestStreak', _dailyMaxStreak);
    for (int i = 0; i < 6; i++) {
      await prefs.setInt('daily_guessDist_$i', dailyGuessDistribution[i]);
    }
  }

  Future<void> incrementGame({
    required bool won,
    required int guessCount,
  }) async {
    totalGamesPlayed++;
    if (won) {
      totalWins++;
      currentStreak++;
      if (currentStreak > _maxStreak) _maxStreak = currentStreak;
      if (guessCount >= 1 && guessCount <= 6) {
        guessDistribution[guessCount - 1]++;
      }
    } else {
      currentStreak = 0;
    }

    winPercentage = totalGamesPlayed > 0
        ? (totalWins / totalGamesPlayed) * 100
        : 0.0;

    notifyListeners();
    await saveStatsToPrefs();
    await saveStatsToCloud();
  }

  Future<void> updateDailyStats({
    required bool won,
    required int guessIndex,
  }) async {
    dailyGamesPlayed++;
    if (won) {
      dailyWins++;
      dailyCurrentStreak++;
      if (dailyCurrentStreak > _dailyMaxStreak) {
        _dailyMaxStreak = dailyCurrentStreak;
      }
      if (guessIndex >= 0 && guessIndex < 6) {
        dailyGuessDistribution[guessIndex]++;
      }
    } else {
      dailyCurrentStreak = 0;
    }

    dailyWinPercentage = dailyGamesPlayed > 0
        ? (dailyWins / dailyGamesPlayed) * 100
        : 0.0;

    notifyListeners();
    await saveStatsToPrefs();
    await saveStatsToCloud();
  }

  Future<void> resetStats() async {
    totalGamesPlayed = 0;
    totalWins = 0;
    winPercentage = 0;
    currentStreak = 0;
    _maxStreak = 0;
    guessDistribution = List.filled(6, 0);

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('totalGames');
    await prefs.remove('totalWins');
    await prefs.remove('currentStreak');
    await prefs.remove('bestStreak');
    for (int i = 0; i < 6; i++) {
      await prefs.remove('guessDist_$i');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'stats': {
            'totalGamesPlayed': 0,
            'totalWins': 0,
            'winPercentage': 0,
            'currentStreak': 0,
            'bestStreak': 0,
            'guessDistribution': List.filled(6, 0),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
        },
      );
    }
  }

  Future<void> resetDailyStats() async {
    dailyGamesPlayed = 0;
    dailyWins = 0;
    dailyWinPercentage = 0;
    dailyCurrentStreak = 0;
    _dailyMaxStreak = 0;
    dailyGuessDistribution = List.filled(6, 0);

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('daily_totalGames');
    await prefs.remove('daily_totalWins');
    await prefs.remove('daily_currentStreak');
    await prefs.remove('daily_bestStreak');
    for (int i = 0; i < 6; i++) {
      await prefs.remove('daily_guessDist_$i');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'dailyStats': {
            'dailyGamesPlayed': 0,
            'dailyWins': 0,
            'dailyWinPercentage': 0,
            'dailyCurrentStreak': 0,
            'dailyBestStreak': 0,
            'dailyGuessDistribution': List.filled(6, 0),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
        },
      );
    }
  }

  Future<void> loadStatsFromCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final cloudStats = doc.data()?['stats'];
    final dailyStats = doc.data()?['dailyStats'];

    if (cloudStats != null) {
      totalGamesPlayed = cloudStats['totalGamesPlayed'] ?? 0;
      totalWins = cloudStats['totalWins'] ?? 0;
      winPercentage = (cloudStats['winPercentage'] ?? 0).toDouble();
      currentStreak = cloudStats['currentStreak'] ?? 0;
      _maxStreak = cloudStats['bestStreak'] ?? 0;
      guessDistribution = List<int>.from(
        cloudStats['guessDistribution'] ?? List.filled(6, 0),
      );
    }

    if (dailyStats != null) {
      dailyGamesPlayed = dailyStats['dailyGamesPlayed'] ?? 0;
      dailyWins = dailyStats['dailyWins'] ?? 0;
      dailyWinPercentage = (dailyStats['dailyWinPercentage'] ?? 0).toDouble();
      dailyCurrentStreak = dailyStats['dailyCurrentStreak'] ?? 0;
      _dailyMaxStreak = dailyStats['dailyBestStreak'] ?? 0;
      dailyGuessDistribution = List<int>.from(
        dailyStats['dailyGuessDistribution'] ?? List.filled(6, 0),
      );
    }

    notifyListeners();
  }

  void listenToCloudStats() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      debugPrint(
        "⚠️ [StatsProvider] Listener not started — user null or anonymous.",
      );
      return;
    }

    _statsSubscription?.cancel();

    _statsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (doc) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null || currentUser.isAnonymous) {
              debugPrint(
                "⛔ [StatsProvider] User signed out during listener event — skipping update.",
              );
              return;
            }

            final data = doc.data();
            if (data == null) return;

            final cloudStats = data['stats'];
            final dailyStats = data['dailyStats'];

            if (cloudStats is Map<String, dynamic>) {
              totalGamesPlayed = cloudStats['totalGamesPlayed'] ?? 0;
              totalWins = cloudStats['totalWins'] ?? 0;
              winPercentage = (cloudStats['winPercentage'] ?? 0).toDouble();
              currentStreak = cloudStats['currentStreak'] ?? 0;
              _maxStreak = cloudStats['bestStreak'] ?? 0;
              final dist = cloudStats['guessDistribution'];
              if (dist is List) {
                guessDistribution = List<int>.from(dist.map((e) => e ?? 0));
              }
            }

            if (dailyStats is Map<String, dynamic>) {
              dailyGamesPlayed = dailyStats['dailyGamesPlayed'] ?? 0;
              dailyWins = dailyStats['dailyWins'] ?? 0;
              dailyWinPercentage = (dailyStats['dailyWinPercentage'] ?? 0)
                  .toDouble();
              dailyCurrentStreak = dailyStats['dailyCurrentStreak'] ?? 0;
              _dailyMaxStreak = dailyStats['dailyBestStreak'] ?? 0;
              final dailyDist = dailyStats['dailyGuessDistribution'];
              if (dailyDist is List) {
                dailyGuessDistribution = List<int>.from(
                  dailyDist.map((e) => e ?? 0),
                );
              }
            }

            notifyListeners();
          },
          onError: (error) {
            debugPrint("🔥 [StatsProvider] Firestore listener error: $error");
          },
          cancelOnError: true,
        );
  }

  Future<void> cancelCloudListener() async {
    await _statsSubscription?.cancel();
    _statsSubscription = null;
  }

  Future<void> saveStatsToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'stats': {
        'totalGamesPlayed': totalGamesPlayed,
        'totalWins': totalWins,
        'winPercentage': winPercentage,
        'currentStreak': currentStreak,
        'bestStreak': _maxStreak,
        'guessDistribution': guessDistribution,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      'dailyStats': {
        'dailyGamesPlayed': dailyGamesPlayed,
        'dailyWins': dailyWins,
        'dailyWinPercentage': dailyWinPercentage,
        'dailyCurrentStreak': dailyCurrentStreak,
        'dailyBestStreak': _dailyMaxStreak,
        'dailyGuessDistribution': dailyGuessDistribution,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    cancelCloudListener();
    super.dispose();
  }
}
