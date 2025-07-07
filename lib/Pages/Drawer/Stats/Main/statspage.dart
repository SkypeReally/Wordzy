import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Stat%20Parts/daily_stats.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Stat%20Parts/general_stats.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: PageView(children: [GeneralStatsView(), DailyStatsView()]),
    );
  }
}
