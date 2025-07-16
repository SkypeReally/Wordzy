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
  Map<int, String?> outcomeMap = {}; // 'win', 'loss', or null
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOutcomeStatus();
  }

  Future<void> _checkOutcomeStatus() async {
    final Map<int, String?> result = {};
    for (final length in wordLengths) {
      result[length] = await DailyWordPlayedTracker.getOutcomeToday(
        length,
      ); // ✅ use outcome
    }
    setState(() {
      outcomeMap = result;
      isLoading = false;
    });
  }

  void _handleTileTap(int length) async {
    final outcome = outcomeMap[length];
    if (outcome != null) {
      showAlreadyPlayedDialog(context);
      return;
    }

    final today = DateTime.now();
    await DailyWordService.loadDailyWords();
    final word = DailyWordService.getDailyWord(length, today);

    if (word.isEmpty) {
      debugPrint("🚫 No daily word for length $length on $today");
      return;
    }

    await Navigator.of(context).push(
      createSlideRoute(
        PlayGamePage(
          fixedWord: word,
          isDailyMode: true,
          dailyWordLength: length,
        ),
      ),
    );

    await _checkOutcomeStatus(); // 🔄 refresh after game
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
          outcomeMap: outcomeMap, // ✅ pass new map
          onTileTap: _handleTileTap,
        ),
      ),
    );
  }
}
