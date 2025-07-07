import 'package:flutter/material.dart';

void showEndGameDialog({
  required BuildContext context,
  required bool won,
  required String answerWord,
  required bool isDailyMode,
  required VoidCallback onNewGame,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  showDialog(
    context: context,
    barrierDismissible: false, // prevent accidental dismissal
    builder: (_) => AlertDialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            won ? Icons.celebration : Icons.cancel,
            size: 48,
            color: won ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            won ? "You Won!" : "You Lost!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "The word was: $answerWord",
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.85)),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.home),
                label: const Text("Menu"),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  foregroundColor: textColor,
                  backgroundColor: isDark
                      ? Colors.white10
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              if (!isDailyMode)
                TextButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text("New Game"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNewGame();
                  },
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
