import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsProvider with ChangeNotifier {
  // 🔵 General Stats
  int totalGamesPlayed = 0;
  int totalWins = 0;
  double winPercentage = 0.0;
  int currentStreak = 0;
  int bestStreak = 0;
  List<int> guessDistribution = List.filled(6, 0);

  // 🟡 Daily Stats
  int dailyGamesPlayed = 0;
  int dailyWins = 0;
  double dailyWinPercentage = 0.0;
  int dailyCurrentStreak = 0;
  int dailyBestStreak = 0;
  List<int> dailyGuessDistribution = List.filled(6, 0);

  StreamSubscription<DocumentSnapshot>? _statsSubscription;

  StatsProvider() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔵 General
    totalGamesPlayed = prefs.getInt('totalGames') ?? 0;
    totalWins = prefs.getInt('totalWins') ?? 0;
    currentStreak = prefs.getInt('currentStreak') ?? 0;
    bestStreak = prefs.getInt('bestStreak') ?? 0;

    winPercentage = totalGamesPlayed > 0
        ? (totalWins / totalGamesPlayed) * 100
        : 0.0;

    for (int i = 0; i < 6; i++) {
      guessDistribution[i] = prefs.getInt('guessDist_$i') ?? 0;
    }

    // 🟡 Daily
    dailyGamesPlayed = prefs.getInt('daily_totalGames') ?? 0;
    dailyWins = prefs.getInt('daily_totalWins') ?? 0;
    dailyCurrentStreak = prefs.getInt('daily_currentStreak') ?? 0;
    dailyBestStreak = prefs.getInt('daily_bestStreak') ?? 0;

    dailyWinPercentage = dailyGamesPlayed > 0
        ? (dailyWins / dailyGamesPlayed) * 100
        : 0.0;

    for (int i = 0; i < 6; i++) {
      dailyGuessDistribution[i] = prefs.getInt('daily_guessDist_$i') ?? 0;
    }

    notifyListeners();
  }

  Future<void> saveStatsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔵 General
    await prefs.setInt('totalGames', totalGamesPlayed);
    await prefs.setInt('totalWins', totalWins);
    await prefs.setInt('currentStreak', currentStreak);
    await prefs.setInt('bestStreak', bestStreak);
    for (int i = 0; i < guessDistribution.length; i++) {
      await prefs.setInt('guessDist_$i', guessDistribution[i]);
    }

    // 🟡 Daily
    await prefs.setInt('daily_totalGames', dailyGamesPlayed);
    await prefs.setInt('daily_totalWins', dailyWins);
    await prefs.setInt('daily_currentStreak', dailyCurrentStreak);
    await prefs.setInt('daily_bestStreak', dailyBestStreak);
    for (int i = 0; i < dailyGuessDistribution.length; i++) {
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
      if (currentStreak > bestStreak) bestStreak = currentStreak;
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
      if (dailyCurrentStreak > dailyBestStreak) {
        dailyBestStreak = dailyCurrentStreak;
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
    bestStreak = 0;
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

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'stats': {
          'totalGamesPlayed': 0,
          'totalWins': 0,
          'winPercentage': 0,
          'currentStreak': 0,
          'bestStreak': 0,
          'guessDistribution': List.filled(6, 0),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      });
    }
  }

  Future<void> resetDailyStats() async {
    dailyGamesPlayed = 0;
    dailyWins = 0;
    dailyWinPercentage = 0;
    dailyCurrentStreak = 0;
    dailyBestStreak = 0;
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

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dailyStats': {
          'dailyGamesPlayed': 0,
          'dailyWins': 0,
          'dailyWinPercentage': 0,
          'dailyCurrentStreak': 0,
          'dailyBestStreak': 0,
          'dailyGuessDistribution': List.filled(6, 0),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      });
    }
  }

  Future<void> loadStatsFromCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final cloudStats = doc.data()?['stats'];
    final dailyStats = doc.data()?['dailyStats'];

    if (cloudStats != null) {
      totalGamesPlayed = cloudStats['totalGamesPlayed'] ?? 0;
      totalWins = cloudStats['totalWins'] ?? 0;
      winPercentage = (cloudStats['winPercentage'] ?? 0).toDouble();
      currentStreak = cloudStats['currentStreak'] ?? 0;
      bestStreak = cloudStats['bestStreak'] ?? 0;
      guessDistribution = List<int>.from(
        cloudStats['guessDistribution'] ?? List.filled(6, 0),
      );
    }

    if (dailyStats != null) {
      dailyGamesPlayed = dailyStats['dailyGamesPlayed'] ?? 0;
      dailyWins = dailyStats['dailyWins'] ?? 0;
      dailyWinPercentage = (dailyStats['dailyWinPercentage'] ?? 0).toDouble();
      dailyCurrentStreak = dailyStats['dailyCurrentStreak'] ?? 0;
      dailyBestStreak = dailyStats['dailyBestStreak'] ?? 0;
      dailyGuessDistribution = List<int>.from(
        dailyStats['dailyGuessDistribution'] ?? List.filled(6, 0),
      );
    }

    notifyListeners();
  }

  void listenToCloudStats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _statsSubscription?.cancel(); // Cancel previous if any

    _statsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
          final cloudStats = doc.data()?['stats'];
          final dailyStats = doc.data()?['dailyStats'];

          if (cloudStats != null) {
            totalGamesPlayed = cloudStats['totalGamesPlayed'] ?? 0;
            totalWins = cloudStats['totalWins'] ?? 0;
            winPercentage = (cloudStats['winPercentage'] ?? 0).toDouble();
            currentStreak = cloudStats['currentStreak'] ?? 0;
            bestStreak = cloudStats['bestStreak'] ?? 0;
            guessDistribution = List<int>.from(
              cloudStats['guessDistribution'] ?? List.filled(6, 0),
            );
          }

          if (dailyStats != null) {
            dailyGamesPlayed = dailyStats['dailyGamesPlayed'] ?? 0;
            dailyWins = dailyStats['dailyWins'] ?? 0;
            dailyWinPercentage = (dailyStats['dailyWinPercentage'] ?? 0)
                .toDouble();
            dailyCurrentStreak = dailyStats['dailyCurrentStreak'] ?? 0;
            dailyBestStreak = dailyStats['dailyBestStreak'] ?? 0;
            dailyGuessDistribution = List<int>.from(
              dailyStats['dailyGuessDistribution'] ?? List.filled(6, 0),
            );
          }

          notifyListeners();
        });
  }

  void cancelCloudListener() {
    _statsSubscription?.cancel();
    _statsSubscription = null;
  }

  Future<void> saveStatsToCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final stats = {
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'winPercentage': winPercentage,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'guessDistribution': guessDistribution,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    final dailyStats = {
      'dailyGamesPlayed': dailyGamesPlayed,
      'dailyWins': dailyWins,
      'dailyWinPercentage': dailyWinPercentage,
      'dailyCurrentStreak': dailyCurrentStreak,
      'dailyBestStreak': dailyBestStreak,
      'dailyGuessDistribution': dailyGuessDistribution,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'stats': stats,
      'dailyStats': dailyStats,
    }, SetOptions(merge: true));
  }
}
