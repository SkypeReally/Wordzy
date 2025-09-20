import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in Page/Main/sign_in_page.dart';
import 'package:gmae_wordle/Game Mechanics/guessrow.dart';
import 'package:gmae_wordle/Game Mechanics/lettermatch.dart';
import 'package:gmae_wordle/Daily Word/dialyword_tracker.dart';
import 'package:gmae_wordle/Instances/fade_message.dart';
import 'package:gmae_wordle/Provider/category_progress_provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
// import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/Service/dailyword_service.dart';
// import 'package:gmae_wordle/Service/sound_service.dart';
// import 'package:gmae_wordle/Service/vibration_service.dart';
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
      if (dailyWordLength == null) {
        debugPrint("❌ Daily word length is null!");
        return;
      }
      final played = await DailyWordPlayedTracker.hasPlayedToday(
        dailyWordLength!,
      );
      if (played) {
        debugPrint("ℹ️ Daily word already played today.");
        onAlreadyPlayed?.call();
        return;
      }
    }

    await restartGame();

    debugPrint(
      "📋 Mode: ${isDailyMode
          ? 'Daily'
          : category != null
          ? 'Category'
          : 'Normal'}",
    );
    debugPrint("📋 Provided dailyWordLength: $dailyWordLength");
    debugPrint(
      "📋 Final word length used: ${isDailyMode ? dailyWordLength : wordLength}",
    );
  }

  void showCenterFadeMessage(String message) {
    final overlay = Overlay.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: FadeMessageWidget(
              message: message,
              isDarkMode: isDarkMode,
              onFadeComplete: () => overlayEntry.remove(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  void handleLastFlipDone() {
    debugPrint("🌀 Final tile flip complete. Calling onGameOver...");
    if (!gameOver) {
      debugPrint("⚠️ Skipped onGameOver: gameOver was false!");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final guessedWord = guesses.last.letters.join();
        final won = guessedWord == answerWord;
        debugPrint("🎯 Game ended. Won: $won");
        onGameOver?.call(won, answerWord);
      }
    });
  }

  Future<void> restartGame() async {
    hasUsedHint = false;
    final int length = isDailyMode ? dailyWordLength! : wordLength;

    if (fixedWord != null) {
      answerWord = fixedWord!;
      debugPrint("🔒 Fixed Word Mode: $answerWord");
    } else if (isDailyMode) {
      answerWord = DailyWordService.getDailyWord(length, DateTime.now());
      debugPrint("📆 Daily Word Mode [$length]: $answerWord");
    } else if (category != null) {
      final progress = context.read<CategoryProgressProvider>();
      final allWords = WordListService.getCategoryWords(category!, length);
      final usedWords = progress.getFoundWords(category!);
      final remainingWords = allWords
          .where((word) => !usedWords.contains(word.toUpperCase()))
          .toList();

      if (remainingWords.isEmpty) {
        answerWord = allWords[Random().nextInt(allWords.length)];
        debugPrint(
          "🏁 Category '$category' - All found. Picking random: $answerWord",
        );
      } else {
        remainingWords.shuffle();
        answerWord = remainingWords.first;
        debugPrint("📚 Category '$category' - Picked new word: $answerWord");
      }
    } else {
      answerWord = await WordListService.getRandomWord(length);
      debugPrint("🎲 Normal Mode [$length]: $answerWord");
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
    debugPrint("🟢 Word Length: $length");
  }

  Future<void> handleKeyPress(String key) async {
    if (isFlipping || gameOver) return;

    final settings = context.read<SettingsProvider>();
    final int length = isDailyMode ? dailyWordLength! : wordLength;

    if (key == '⌫') {
      for (int i = length - 1; i >= 0; i--) {
        if (currentGuess[i].isNotEmpty) {
          if (i == hintedIndex) {
            showCenterFadeMessage("Hinted tile cannot be deleted.");
            return;
          }
          currentGuess[i] = '';
          break;
        }
      }
      refreshUI();
    } else if (key == 'ENTER') {
      if (currentGuess.where((c) => c.isNotEmpty).length == length) {
        if (_violatesHardModeRules(currentGuess)) {
          if (context.mounted) {
            showCenterFadeMessage(
              "You must use known hints correctly in Hard Mode.",
            );
          }
          return;
        }
        await _processGuess(settings, length);
        hintedIndex = null;
        hintedMatch = null;
      }
    } else if (RegExp(r'^[A-Z]$').hasMatch(key)) {
      for (int i = 0; i < length; i++) {
        if (currentGuess[i].isEmpty && i != hintedIndex) {
          currentGuess[i] = key;
          break;
        }
      }
      refreshUI();
    }

    debugPrint("⌨️ Guess: ${currentGuess.join()}");
  }

  Future<void> _processGuess(SettingsProvider settings, int length) async {
    isFlipping = true;

    final guessString = currentGuess.join().toUpperCase();

    final generalList = WordListService.getListForLength(length);
    final isInGeneralList = generalList.contains(guessString);

    bool isInCategoryList = false;
    if (category != null) {
      final categoryList = WordListService.getCategoryWords(category!, length);
      isInCategoryList = categoryList.contains(guessString);
    }

    if (!isInGeneralList && !isInCategoryList) {
      showCenterFadeMessage("Not a valid word.");
      isFlipping = false;
      return;
    }

    final evaluated = evaluateGuess(currentGuess, answerWord);

    final newRow = Guessrow(
      letters: List.from(currentGuess),
      matches: evaluated,
    );

    guesses.add(newRow);
    currentGuess
      ..clear()
      ..addAll(List.filled(length, ''));

    for (int i = 0; i < evaluated.length; i++) {
      if (i == hintedIndex) continue;

      final letter = newRow.letters[i];
      final match = newRow.matches[i];
      final existing = keyColors[letter];

      if (existing == null ||
          _matchPriority(match) > _matchPriority(existing)) {
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

  int _matchPriority(LetterMatch match) {
    switch (match) {
      case LetterMatch.correct:
        return 3;
      case LetterMatch.present:
        return 2;
      case LetterMatch.absent:
        return 1;
      case LetterMatch.none:
        return 0;
    }
  }

  Future<void> _endGame(bool won, SettingsProvider settings, int length) async {
    final stats = context.read<StatsProvider>();
    final guessIndex = guesses.length - 1;

    gameOver = true;

    if (isDailyMode && dailyWordLength != null) {
      await stats.updateDailyStats(won: won, guessIndex: guessIndex);
      await DailyWordPlayedTracker().markPlayed(
        DateTime.now(),
        dailyWordLength!,
        won: won,
      );
    } else if (category != null) {
    } else {
      await stats.incrementGame(won: won, guessCount: guessIndex + 1);
    }

    // if (settings.isSoundEnabled) {
    //   won ? SoundService.playSuccess() : SoundService.playError();
    // }
    // if (settings.isHapticEnabled) {
    //   won ? VibrationService.vibrateSuccess() : VibrationService.vibrateError();
    // }
  }

  List<LetterMatch> evaluateGuess(List<String> guess, String answer) {
    List<LetterMatch> result = List.filled(guess.length, LetterMatch.absent);
    List<bool> taken = List.filled(answer.length, false);

    for (int i = 0; i < guess.length; i++) {
      if (i == hintedIndex) {
        result[i] = hintedMatch!;
        taken[i] = true;
        continue;
      }

      if (guess[i] == answer[i]) {
        result[i] = LetterMatch.correct;
        taken[i] = true;
      }
    }

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
    if (!context.mounted) return;

    final settings = context.read<SettingsProvider>();

    if (!settings.hintsEnabled || isDailyMode || settings.hardMode) {
      showCenterFadeMessage("Hints aren't allowed in this mode.");
      return;
    }

    final rand = Random();
    final answerLetters = answerWord.split('');
    final usedLetters = guesses.expand((g) => g.letters).toSet();
    final knownCorrect = List<String?>.filled(answerLetters.length, null);
    for (final row in guesses) {
      final limit = min(row.letters.length, knownCorrect.length);
      for (int i = 0; i < limit; i++) {
        if (row.matches[i] == LetterMatch.correct) {
          knownCorrect[i] = row.letters[i];
        }
      }
    }

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
      showCenterFadeMessage("Hint: '$letter' is correct at position ${i + 1}.");
      return;
    }

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
          showCenterFadeMessage("Hint: '$ch' is in the word (wrong position).");
          return;
        }
      }
    }

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
      showCenterFadeMessage("Hint: '$ch' is not in the word.");
      return;
    }

    showCenterFadeMessage("No more hints available.");
  }

  LetterMatch? getHintedMatch(int index) {
    return index == hintedIndex ? hintedMatch : null;
  }
}
