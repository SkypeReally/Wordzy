import 'package:flutter/material.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Provider/streak_freeze.dart';
import 'package:provider/provider.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    final stats = context.watch<StatsProvider>();
    final freezeCount = context.watch<StreakFreezeProvider>().freezeCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Streak & Freeze"),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreakCard(context, stats.currentStreak, stats.maxStreak),
            const SizedBox(height: 20),
            _buildFreezeCard(context, freezeCount),
            const SizedBox(height: 20),
            Text(
              "What is Streak Freeze?",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Streak Freeze protects your current streak if you lose a game. "
              "When active, it automatically prevents your streak from resetting.\n\n"
              "One freeze is consumed per loss.\n\n"
              "You can stack multiple freezes for safety.",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int current, int max) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.deepOrange.shade400 : Colors.orange.shade100,
      child: ListTile(
        leading: Icon(
          Icons.local_fire_department,
          color: isDark ? Colors.white : Colors.deepOrange,
        ),
        title: Text(
          "Current Streak: $current",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Max Streak: $max",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }

  Widget _buildFreezeCard(BuildContext context, int freezeCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.lightBlue.shade400 : Colors.blue.shade100,
      child: ListTile(
        leading: Icon(
          Icons.ac_unit,
          color: isDark ? Colors.white : Colors.blueAccent,
        ),
        title: Text(
          "Streak Freezes Available",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          "$freezeCount",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
