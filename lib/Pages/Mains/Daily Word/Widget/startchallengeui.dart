import 'package:flutter/material.dart';
import 'package:gmae_wordle/Daily%20Word/Daily%20Selector/Main/dailyword_selector.dart';

class StartChallengeButton extends StatelessWidget {
  const StartChallengeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Start Daily Challenge',
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DailyWordLengthSelectorPage(),
            ),
          );
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow),
            SizedBox(width: 8),
            Text("Start Challenge"),
          ],
        ),
      ),
    );
  }
}
