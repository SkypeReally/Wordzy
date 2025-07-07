import 'package:flutter/material.dart';

class DailyCountdownCard extends StatelessWidget {
  final Duration timeLeft;

  const DailyCountdownCard({super.key, required this.timeLeft});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme
        .colorScheme
        .primary; // You can also use `tertiary` or `secondary` if preferred

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text("Next word unlocks in:", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            _formatDuration(timeLeft),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
