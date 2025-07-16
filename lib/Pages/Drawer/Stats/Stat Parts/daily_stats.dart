import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/guess_distrib_bar.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/stat_reset.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/stats_helper.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/stats_overview.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';

class DailyStatsView extends StatelessWidget {
  const DailyStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = context.watch<StatsProvider>();

    final played = stats.dailyGamesPlayed;
    final wins = stats.dailyWins;
    final winPercent = stats.dailyWinPercentage;
    final streak = stats.dailyCurrentStreak;
    final best = stats.maxStreak;
    final distribution = stats.dailyGuessDistribution;

    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? Colors.redAccent : theme.colorScheme.error;
    final foreground = isDark ? Colors.white : theme.colorScheme.onError;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildSectionTitle(context, "Daily Stats"),
            StatsOverview(
              played: played,
              wins: wins,
              winPercent: winPercent,
              streak: streak,
              best: best,
              textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            const SizedBox(height: 16),
            buildSectionTitle(context, "Daily Guess Distribution"),
            GuessDistributionChart(distribution: distribution),
            const SizedBox(height: 32),
            StatsResetButton(
              label: "Reset Daily Stats",
              backgroundColor: background,
              foregroundColor: foreground,
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context: context,
                  title: "Reset Daily Stats",
                  message: "Are you sure you want to reset your daily stats?",
                  icon: Icons.warning,
                  confirmText: "Reset",
                  confirmColor: background,
                );
                if (confirm == true) {
                  context.read<StatsProvider>().resetDailyStats();
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
