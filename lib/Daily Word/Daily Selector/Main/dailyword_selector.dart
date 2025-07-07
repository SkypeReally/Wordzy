import 'package:flutter/material.dart';
import 'package:gmae_wordle/Daily%20Word/Daily%20Selector/Core/dailyword_grid.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/already_played.dart';
import 'package:gmae_wordle/Service/dailyword_service.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Main/gamepage.dart';
import 'package:gmae_wordle/Instances/page_transition.dart';

class DailyWordLengthSelectorPage extends StatefulWidget {
  const DailyWordLengthSelectorPage({super.key});

  @override
  State<DailyWordLengthSelectorPage> createState() =>
      _DailyWordLengthSelectorPageState();
}

class _DailyWordLengthSelectorPageState
    extends State<DailyWordLengthSelectorPage> {
  final List<int> wordLengths = [3, 4, 5, 6, 7, 8];
  Map<int, bool> playedMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPlayedStatus();
  }

  Future<void> _checkPlayedStatus() async {
    final Map<int, bool> result = {};
    for (final length in wordLengths) {
      result[length] = await DailyWordPlayedTracker.hasPlayedToday(length);
    }
    setState(() {
      playedMap = result;
      isLoading = false;
    });
  }

  void _handleTileTap(int length) async {
    final played = playedMap[length] ?? false;

    if (played) {
      showAlreadyPlayedDialog(context);
    } else {
      final today = DateTime.now();
      final word = DailyWordService.getDailyWord(length, today);

      await Navigator.of(context).push(
        createSlideRoute(
          PlayGamePage(
            wordLength: length,
            fixedWord: word,
            isDailyMode: true,
            dailyWordLength: length,
          ),
        ),
      );

      // 🔁 Refresh UI on return
      await _checkPlayedStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Daily Word Length"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: DailyWordGrid(
          wordLengths: wordLengths,
          playedMap: playedMap,
          onTileTap: _handleTileTap,
        ),
      ),
    );
  }
}
