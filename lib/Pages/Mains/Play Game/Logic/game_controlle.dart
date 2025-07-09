import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in Page/Main/sign_in_page.dart';
import 'package:gmae_wordle/Game Mechanics/guessrow.dart';
import 'package:gmae_wordle/Game Mechanics/lettermatch.dart';
import 'package:gmae_wordle/Daily Word/dialyword_tracker.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/Service/dailyword_service.dart';
import 'package:gmae_wordle/Service/sound_service.dart';
import 'package:gmae_wordle/Service/vibration_service.dart';
import 'package:gmae_wordle/Service/wordlist.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class GameController {
  final BuildContext context;
  final int wordLength;
  final bool isDailyMode;
  final int? dailyWordLength;
  final String? fixedWord;
  final String? category;

  final void Function(bool won, String answer)? onGameOver;
  final VoidCallback? onAlreadyPlayed;
  final VoidCallback refreshUI;

  late String answerWord;
  bool isFlipping = false;
  bool gameOver = false;
  bool isWordLoaded = false;
  bool hasUsedHint = false;

  final List<String> currentGuess = [];
  final List<Guessrow> guesses = [];
  final Map<String, LetterMatch> keyColors = {};

  int? hintedIndex;
  LetterMatch? hintedMatch;

  GameController({
    required this.context,
    required this.wordLength,
    required this.isDailyMode,
    required this.dailyWordLength,
    required this.fixedWord,
    required this.onGameOver,
    required this.onAlreadyPlayed,
    required this.refreshUI,
    this.category,
  });

  bool _violatesHardModeRules(List<String> guess) {
    if (!context.read<SettingsProvider>().hardMode) return false;
    for (final pastGuess in guesses) {
      for (int i = 0; i < pastGuess.letters.length; i++) {
        final letter = pastGuess.letters[i];
        final match = pastGuess.matches[i];
        if (match == LetterMatch.correct && guess[i] != letter) return true;
        if (match == LetterMatch.present && !guess.contains(letter))
          return true;
      }
    }
    return false;
  }

  Future<void> initializeGame() async {
    final user = FirebaseAuth.instance.currentUser;

    if (isDailyMode && (user == null || user.isAnonymous)) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Sign In Required"),
          content: const Text("Please sign in to access the Daily Word."),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Go to Login"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
      return;
    }

    if (isDailyMode) {
      if (dailyWordLength == null) return;
      final played = await DailyWordPlayedTracker.hasPlayedToday(
        dailyWordLength!,
      );
      if (played) {
        onAlreadyPlayed?.call();
        return;
      }
    }

    await restartGame();
  }

  void handleLastFlipDone() {
    if (!gameOver) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        onGameOver?.call(guesses.last.letters.join() == answerWord, answerWord);
      }
    });
  }

  Future<void> restartGame() async {
    hasUsedHint = false;

    final int length = isDailyMode
        ? dailyWordLength!
        : context.read<WordLengthProvider>().wordLength;

    if (fixedWord != null) {
      answerWord = fixedWord!;
    } else if (isDailyMode) {
      answerWord = DailyWordService.getDailyWord(length, DateTime.now());
    } else if (category != null) {
      answerWord = await WordListService.getRandomWordFromCategory(
        category!,
        length,
      );
    } else {
      answerWord = await WordListService.getRandomWord(length);
    }

    currentGuess
      ..clear()
      ..addAll(List.filled(length, ''));
    guesses.clear();
    keyColors.clear();
    gameOver = false;
    isFlipping = false;
    isWordLoaded = true;

    hintedIndex = null;
    hintedMatch = null;
    debugPrint("🎯 Game started. Target word: $answerWord");
  }

  Future<void> handleKeyPress(String key) async {
    if (isFlipping || gameOver) return;

    final settings = context.read<SettingsProvider>();
    final int length = isDailyMode ? dailyWordLength! : wordLength;

    if (key == '⌫') {
      for (int i = length - 1; i >= 0; i--) {
        if (currentGuess[i].isNotEmpty) {
          // ❌ Don't allow deleting hinted tile
          if (i == hintedIndex) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hinted tile cannot be deleted.")),
            );
            return;
          }
          currentGuess[i] = '';
          break;
        }
      }
      if (settings.isSoundEnabled) SoundService.playClick();
      if (settings.isHapticEnabled) VibrationService.vibrate();
      refreshUI();
    } else if (key == 'ENTER') {
      if (currentGuess.where((c) => c.isNotEmpty).length == length) {
        if (_violatesHardModeRules(currentGuess)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "You must use known hints correctly in Hard Mode.",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }
        await _processGuess(settings, length);

        // ✅ Clear hint after processing the guess
        hintedIndex = null;
        hintedMatch = null;
      }
    } else if (RegExp(r'^[A-Z]$').hasMatch(key)) {
      for (int i = 0; i < length; i++) {
        // ✅ Skip hinted tile while typing
        if (currentGuess[i].isEmpty && i != hintedIndex) {
          currentGuess[i] = key;
          break;
        }
      }
      if (settings.isSoundEnabled) SoundService.playClick();
      if (settings.isHapticEnabled) VibrationService.vibrate();
      refreshUI();
    }

    debugPrint("⌨️ Guess: ${currentGuess.join()}");
  }

  Future<void> _processGuess(SettingsProvider settings, int length) async {
    isFlipping = true;
    final guessString = currentGuess.join();
    final evaluated = evaluateGuess(currentGuess, answerWord);

    final newRow = Guessrow(
      letters: List.from(currentGuess),
      matches: evaluated,
    );

    guesses.add(newRow);
    currentGuess
      ..clear()
      ..addAll(List.filled(length, ''));

    if (settings.isSoundEnabled) SoundService.playClick();
    if (settings.isHapticEnabled) VibrationService.vibrate();

    for (int i = 0; i < evaluated.length; i++) {
      // ✅ Don't update hinted tile color
      if (i == hintedIndex) continue;

      final letter = newRow.letters[i];
      final match = newRow.matches[i];
      final existing = keyColors[letter];
      if (existing == null || match.index > existing.index) {
        keyColors[letter] = match;
      }
    }

    final won = guessString == answerWord;
    final over = won || guesses.length >= 6;
    if (over) await _endGame(won, settings, length);
    isFlipping = false;
  }

  List<LetterMatch> getCurrentRowMatches() {
    return evaluateGuess(currentGuess, answerWord);
  }

  void consumeHint() {
    hasUsedHint = true;
  }

  void resetHintUsage() {
    hasUsedHint = false;
  }

  Future<void> _endGame(bool won, SettingsProvider settings, int length) async {
    final stats = context.read<StatsProvider>();
    final guessIndex = guesses.length - 1;

    if (isDailyMode && dailyWordLength != null) {
      await stats.updateDailyStats(won: won, guessIndex: guessIndex);
      await DailyWordPlayedTracker().markPlayed(
        DateTime.now(),
        dailyWordLength!,
      );
    } else {
      await stats.incrementGame(won: won, guessCount: guessIndex + 1);
    }

    if (settings.isSoundEnabled) {
      won ? SoundService.playSuccess() : SoundService.playError();
    }
    if (settings.isHapticEnabled) {
      won ? VibrationService.vibrateSuccess() : VibrationService.vibrateError();
    }

    gameOver = true;

    // ❌ REMOVE this — now handled in handleLastFlipDone:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (context.mounted) onGameOver?.call(won, answerWord);
    // });
  }

  List<LetterMatch> evaluateGuess(List<String> guess, String answer) {
    List<LetterMatch> result = List.filled(guess.length, LetterMatch.absent);
    List<bool> taken = List.filled(answer.length, false);

    // ✅ First pass: green (correct)
    for (int i = 0; i < guess.length; i++) {
      if (i == hintedIndex) {
        result[i] = hintedMatch!; // ✅ Use stored match
        taken[i] = true; // ✅ Mark taken
        continue;
      }

      if (guess[i] == answer[i]) {
        result[i] = LetterMatch.correct;
        taken[i] = true;
      }
    }

    // ✅ Second pass: yellow
    for (int i = 0; i < guess.length; i++) {
      if (result[i] == LetterMatch.correct) continue;
      for (int j = 0; j < answer.length; j++) {
        if (!taken[j] && guess[i] == answer[j]) {
          result[i] = LetterMatch.present;
          taken[j] = true;
          break;
        }
      }
    }

    return result;
  }

  Future<void> useHint() async {
    if (!context.mounted) return; // ✅ Prevent usage if unmounted

    final settings = context.read<SettingsProvider>();

    if (!settings.hintsEnabled || isDailyMode || settings.hardMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hints aren't allowed in this mode.")),
      );
      return;
    }

    final rand = Random();
    final answerLetters = answerWord.split('');
    final usedLetters = guesses.expand((g) => g.letters).toSet();
    final knownCorrect = List<String?>.filled(answerLetters.length, null);

    for (final row in guesses) {
      for (int i = 0; i < row.letters.length; i++) {
        if (row.matches[i] == LetterMatch.correct) {
          knownCorrect[i] = row.letters[i];
        }
      }
    }

    // Green Hint
    final greenOptions = <int>[];
    for (int i = 0; i < answerLetters.length; i++) {
      if (knownCorrect[i] == null && currentGuess[i].isEmpty) {
        greenOptions.add(i);
      }
    }
    if (greenOptions.isNotEmpty) {
      final i = greenOptions[rand.nextInt(greenOptions.length)];
      final letter = answerLetters[i];
      currentGuess[i] = letter;
      hintedIndex = i;
      hintedMatch = LetterMatch.correct;
      keyColors[letter] = LetterMatch.correct;
      hasUsedHint = true;
      refreshUI();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hint: '$letter' is correct at position ${i + 1}."),
        ),
      );
      return;
    }

    // Yellow Hint
    for (int i = 0; i < answerLetters.length; i++) {
      final ch = answerLetters[i];
      if (knownCorrect.contains(ch)) continue;
      if (usedLetters.contains(ch)) continue;

      for (int j = 0; j < currentGuess.length; j++) {
        if (j == i) continue;
        if (currentGuess[j].isEmpty) {
          currentGuess[j] = ch;
          hintedIndex = j;
          hintedMatch = LetterMatch.present;
          keyColors[ch] = LetterMatch.present;
          hasUsedHint = true;
          refreshUI();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Hint: '$ch' is in the word (wrong position)."),
            ),
          );
          return;
        }
      }
    }

    // Grey Hint
    final unusedGreys = <String>[];
    for (var i = 0; i < 26; i++) {
      final ch = String.fromCharCode(65 + i);
      if (!answerWord.contains(ch) && !keyColors.containsKey(ch)) {
        unusedGreys.add(ch);
      }
    }
    if (unusedGreys.isNotEmpty) {
      final ch = unusedGreys[rand.nextInt(unusedGreys.length)];
      keyColors[ch] = LetterMatch.absent;
      hasUsedHint = true;
      refreshUI();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hint: '$ch' is not in the word.")),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("No more hints available.")));
  }

  // Add this method so the UI can get the hinted match for coloring
  LetterMatch? getHintedMatch(int index) {
    return index == hintedIndex ? hintedMatch : null;
  }
}
