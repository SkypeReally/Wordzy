import 'package:flutter/material.dart';

void showExitConfirmation(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  showDialog(
    context: context,
    barrierDismissible: false, // prevent accidental dismissal
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      title: Text(
        "Exit Game?",
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      content: Text(
        "You are currently in a game. Would you like to leave?",
        style: TextStyle(color: textColor.withOpacity(0.9)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(); // close dialog
            Navigator.of(context).pop(); // exit game
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
