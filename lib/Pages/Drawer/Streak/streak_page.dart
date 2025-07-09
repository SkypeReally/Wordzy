import 'package:flutter/material.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Provider/streak_freeze.dart';
import 'package:provider/provider.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final stats = context.watch<StatsProvider>();
    final freezeCount = context.watch<StreakFreezeProvider>().freezeCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Streak & Freeze"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreakCard(stats.currentStreak, stats.maxStreak),
            const SizedBox(height: 20),
            _buildFreezeCard(freezeCount),
            const SizedBox(height: 20),
            const Text(
              "What is Streak Freeze?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Streak Freeze protects your current streak if you lose a game. "
              "When active, it automatically prevents your streak from resetting.\n\n"
              "One freeze is consumed per loss.\n\n"
              "You can stack multiple freezes for safety.",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int current, int max) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange.shade100,
      child: ListTile(
        leading: const Icon(
          Icons.local_fire_department,
          color: Colors.deepOrange,
        ),
        title: Text("Current Streak: $current"),
        subtitle: Text("Max Streak: $max"),
      ),
    );
  }

  Widget _buildFreezeCard(int freezeCount) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade100,
      child: ListTile(
        leading: const Icon(Icons.ac_unit, color: Colors.blueAccent),
        title: const Text("Streak Freezes Available"),
        trailing: Text(
          "$freezeCount",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
