import 'package:flutter/material.dart';

class DailyWordTile extends StatelessWidget {
  final int wordLength;
  final bool played;
  final VoidCallback onTap;

  const DailyWordTile({
    super.key,
    required this.wordLength,
    required this.played,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: played
              ? Colors.green
              : isDark
              ? Colors.grey[800]
              : Colors.grey[200],
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
                  color: played ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
              if (played)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
