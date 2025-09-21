import 'package:flutter/material.dart';

void showInstructionsDialog(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'How to Play',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: textColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _instruction("Guess the word in 6 tries."),
            _instruction("Each guess must be a valid word."),
            _instruction("Hit ENTER to submit."),
            const SizedBox(height: 12),
            Text(
              "After each guess, tiles will flip to show:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendTile(
              color: Colors.green,
              label: 'Correct letter in the correct position',
            ),
            _buildLegendTile(
              color: Colors.yellow,
              label: 'Letter exists but in wrong position',
            ),
            _buildLegendTile(
              color: const Color.fromARGB(255, 51, 136, 233),
              label: 'Letter not in the word',
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(ctx).pop(),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: const Text(
            'Got it!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _instruction(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 16)),
  );
}

Widget _buildLegendTile({required Color color, required String label}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        CircleAvatar(radius: 10, backgroundColor: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}
