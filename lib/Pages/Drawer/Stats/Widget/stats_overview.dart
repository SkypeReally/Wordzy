import 'package:flutter/material.dart';

class StatsOverview extends StatelessWidget {
  final int played;
  final int wins;
  final double winPercent;
  final int streak;
  final int best;
  final Color textColor;

  const StatsOverview({
    super.key,
    required this.played,
    required this.wins,
    required this.winPercent,
    required this.streak,
    required this.best,
    required this.textColor,
  });

  Widget _buildStatTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: textColor.withAlpha(178)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatTile("Played", "$played"),
            _buildStatTile("Wins", "$wins"),
            _buildStatTile("Win %", "${winPercent.toStringAsFixed(0)}%"),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatTile("Streak", "$streak"),
            _buildStatTile("Best", "$best"),
          ],
        ),
      ],
    );
  }
}
