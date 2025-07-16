import 'package:flutter/material.dart';

/// Builds a styled section title using the current theme.
Widget buildSectionTitle(BuildContext context, String title) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

/// Shows a reusable confirmation dialog for any action.
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  IconData? icon,
  String cancelText = "Cancel",
  String confirmText = "Confirm",
  Color confirmColor = const Color.fromARGB(255, 161, 8, 8),
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: confirmColor),
            const SizedBox(width: 8),
          ],
          Flexible(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
