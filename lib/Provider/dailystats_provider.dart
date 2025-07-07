import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyStatsProvider with ChangeNotifier {
  int totalGamesPlayed = 0;
  int totalWins = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  List<int> guessDistribution = List.filled(6, 0); // Index 0 → 1st guess

  double get winPercentage =>
      totalGamesPlayed == 0 ? 0 : (totalWins / totalGamesPlayed) * 100;

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    totalGamesPlayed = prefs.getInt('daily_totalGames') ?? 0;
    totalWins = prefs.getInt('daily_totalWins') ?? 0;
    currentStreak = prefs.getInt('daily_currentStreak') ?? 0;
    bestStreak = prefs.getInt('daily_bestStreak') ?? 0;

    guessDistribution = List.generate(
      6,
      (i) => prefs.getInt('daily_guess_$i') ?? 0,
    );

    notifyListeners();
  }

  Future<void> updateStats({required bool won, required int guessIndex}) async {
    final prefs = await SharedPreferences.getInstance();

    totalGamesPlayed++;
    await prefs.setInt('daily_totalGames', totalGamesPlayed);

    if (won) {
      totalWins++;
      currentStreak++;
      bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;

      await prefs.setInt('daily_totalWins', totalWins);
      await prefs.setInt('daily_currentStreak', currentStreak);
      await prefs.setInt('daily_bestStreak', bestStreak);
    } else {
      currentStreak = 0;
      await prefs.setInt('daily_currentStreak', currentStreak);
    }

    if (guessIndex >= 0 && guessIndex < 6) {
      guessDistribution[guessIndex]++;
      await prefs.setInt(
        'daily_guess_$guessIndex',
        guessDistribution[guessIndex],
      );
    }

    notifyListeners();
  }

  Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('daily_totalGames');
    await prefs.remove('daily_totalWins');
    await prefs.remove('daily_currentStreak');
    await prefs.remove('daily_bestStreak');

    for (int i = 0; i < 6; i++) {
      await prefs.remove('daily_guess_$i');
    }

    totalGamesPlayed = 0;
    totalWins = 0;
    currentStreak = 0;
    bestStreak = 0;
    guessDistribution = List.filled(6, 0);

    notifyListeners();
  }
}
