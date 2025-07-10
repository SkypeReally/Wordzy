import 'package:flutter/material.dart';

void showEndGameDialog({
  required BuildContext context,
  required bool won,
  required String? answerWord,
  required bool isDailyMode,
  String? category,
  required VoidCallback onNewGame,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  final isCategory = category != null;

  final title = won
      ? "🎉 You Won!"
      : isCategory
      ? "😢 You Lost"
      : "😢 You Lost";

  final message = won
      ? "The word was: ${answerWord ?? '???'}"
      : isCategory
      ? "Try again with a new word from the \"$category\" category."
      : "The word was: ${answerWord ?? '???'}";

  final tryAgainLabel = isCategory ? "Try Again" : "New Game";

  showDialog(
    context: context,
    barrierDismissible: false,
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
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.85)),
            textAlign: TextAlign.center,
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
              if (!isDailyMode || isCategory)
                TextButton.icon(
                  icon: const Icon(Icons.replay),
                  label: Text(tryAgainLabel),
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
