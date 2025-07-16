import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/guess_distrib_bar.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/stat_reset.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/stats_helper.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Widget/stats_overview.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';

class GeneralStatsView extends StatelessWidget {
  const GeneralStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = context.watch<StatsProvider>();

    final played = stats.totalGamesPlayed;
    final wins = stats.totalWins;
    final winPercent = stats.winPercentage;
    final streak = stats.currentStreak;
    final best = stats.maxStreak;
    final distribution = stats.guessDistribution;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildSectionTitle(context, "General Stats"),
            StatsOverview(
              played: played,
              wins: wins,
              winPercent: winPercent,
              streak: streak,
              best: best,
              textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            const SizedBox(height: 16),
            buildSectionTitle(context, "Guess Distribution"),
            GuessDistributionChart(distribution: distribution),
            const SizedBox(height: 32),
            StatsResetButton(
              label: "Reset General Stats",
              backgroundColor: isDark
                  ? Colors.redAccent
                  : theme.colorScheme.error,
              foregroundColor: isDark
                  ? Colors.white
                  : theme.colorScheme.onError,
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context: context,
                  title: "Reset General Stats",
                  message: "Are you sure you want to reset your general stats?",
                  icon: Icons.warning,
                  confirmText: "Reset",
                  confirmColor: theme.colorScheme.error,
                );
                if (confirm == true) {
                  context.read<StatsProvider>().resetStats();
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
