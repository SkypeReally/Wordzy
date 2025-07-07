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
  Map<int, bool> playedMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayedStatus();
  }

  Future<void> _loadPlayedStatus() async {
    final Map<int, bool> status = {};
    for (final length in wordLengths) {
      status[length] = await DailyWordPlayedTracker.hasPlayedToday(length);
    }

    setState(() {
      playedMap = status;
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
            final played = playedMap[length] ?? false;

            return ElevatedButton.icon(
              icon: played
                  ? const Icon(Icons.check_circle_outline, size: 18)
                  : const Icon(Icons.play_arrow),
              style: ElevatedButton.styleFrom(
                backgroundColor: played
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: played
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (played) {
                  _showAlreadyPlayedDialog();
                } else {
                  await Navigator.pushNamed(
                    context,
                    '/dailyplay',
                    arguments: length,
                  );

                  // 🔁 Recheck status when coming back
                  await _loadPlayedStatus();
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
