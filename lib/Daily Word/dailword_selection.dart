import 'package:flutter/material.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';

class DailyWordLengthSelectionPage extends StatefulWidget {
  const DailyWordLengthSelectionPage({super.key});

  @override
  State<DailyWordLengthSelectionPage> createState() =>
      _DailyWordLengthSelectionPageState();
}

class _DailyWordLengthSelectionPageState
    extends State<DailyWordLengthSelectionPage> {
  final List<int> wordLengths = [3, 4, 5, 6, 7, 8];
  Map<int, String?> outcomeMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final Map<int, String?> status = {};
    for (final length in wordLengths) {
      status[length] = await DailyWordPlayedTracker.getOutcomeToday(length);
    }

    setState(() {
      outcomeMap = status;
      isLoading = false;
    });
  }

  void _showAlreadyPlayedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Already Played"),
        content: const Text(
          "You've already played today's word for this length. Come back tomorrow!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Select Daily Word Length")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: wordLengths.map((length) {
            final outcome = outcomeMap[length];
            Color background;
            Color foreground;
            Icon icon;

            if (outcome == 'win') {
              background = Colors.green.shade600;
              foreground = Colors.white;
              icon = const Icon(Icons.check_circle);
            } else if (outcome == 'loss') {
              background = Colors.red.shade600;
              foreground = Colors.white;
              icon = const Icon(Icons.cancel);
            } else {
              background = Theme.of(context).colorScheme.primary;
              foreground = Colors.white;
              icon = const Icon(Icons.play_arrow);
            }

            return ElevatedButton.icon(
              icon: icon,
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
                foregroundColor: foreground,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (outcome != null) {
                  _showAlreadyPlayedDialog();
                } else {
                  await Navigator.pushNamed(
                    context,
                    '/dailyplay',
                    arguments: length,
                  );

                  // 🔁 Refresh outcome
                  await _loadStatus();
                }
              },
              label: Text(
                "$length Letters",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
