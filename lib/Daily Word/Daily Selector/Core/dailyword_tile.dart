import 'package:flutter/material.dart';

class DailyWordTile extends StatelessWidget {
  final int wordLength;
  final String? outcome;
  final VoidCallback onTap;

  const DailyWordTile({
    super.key,
    required this.wordLength,
    required this.outcome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isWin = outcome == 'win';
    final isLoss = outcome == 'loss';

    Color backgroundColor;
    Color textColor;
    Icon? icon;

    if (isWin) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      icon = const Icon(Icons.check_circle, color: Colors.white, size: 20);
    } else if (isLoss) {
      backgroundColor = Colors.redAccent.shade200;
      textColor = Colors.white;
      icon = null;
    } else {
      backgroundColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
      textColor = theme.colorScheme.onSurface;
      icon = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: backgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$wordLength Letters",
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (icon != null)
                Padding(padding: const EdgeInsets.only(left: 6), child: icon),
            ],
          ),
        ),
      ),
    );
  }
}
