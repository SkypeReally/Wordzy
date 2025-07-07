import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/guessrow.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/Service/dailyword_service.dart';
import 'package:gmae_wordle/Service/sound_service.dart';
import 'package:gmae_wordle/Service/vibration_service.dart';
import 'package:gmae_wordle/Service/wordlist.dart';
import 'package:provider/provider.dart';

class GameController {
  final BuildContext context;
  final int wordLength;
  final bool isDailyMode;
  final int? dailyWordLength;
  final String? fixedWord;
  final void Function(bool won, String answer)? onGameOver;
  final VoidCallback? onAlreadyPlayed;
  final VoidCallback refreshUI;

  late String answerWord;
  bool isFlipping = false;
  bool gameOver = false;
  bool isWordLoaded = false;

  final List<String> currentGuess = [];
  final List<Guessrow> guesses = [];
  final Map<String, LetterMatch> keyColors = {};

  GameController({
    required this.context,
    required this.wordLength,
    required this.isDailyMode,
    required this.dailyWordLength,
    required this.fixedWord,
    required this.onGameOver,
    required this.onAlreadyPlayed,
    required this.refreshUI,
  });

  Future<void> initializeGame() async {
    if (isDailyMode) {
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

  Future<void> restartGame() async {
    final int length = isDailyMode
        ? dailyWordLength!
        : context.read<WordLengthProvider>().wordLength;

    answerWord =
        fixedWord ??
        (isDailyMode
            ? DailyWordService.getDailyWord(length, DateTime.now())
            : await WordListService.getRandomWord(length));

    currentGuess.clear();
    guesses.clear();
    keyColors.clear();
    gameOver = false;
    isFlipping = false;
    isWordLoaded = true;

    debugPrint("🎯 Answer word: $answerWord");
  }

  Future<void> handleKeyPress(String key) async {
    if (isFlipping || gameOver) return;

    final settings = context.read<SettingsProvider>();
    final int length = isDailyMode ? dailyWordLength! : wordLength;

    if (key == '⌫') {
      if (currentGuess.isNotEmpty) {
        currentGuess.removeLast();
        if (settings.isSoundEnabled) SoundService.playClick();
        if (settings.isHapticEnabled) VibrationService.vibrate();
        refreshUI();
      }
    } else if (key == 'ENTER') {
      if (currentGuess.length == length) {
        isFlipping = true;

        final guessString = currentGuess.join('');
        final evaluated = evaluateGuess(currentGuess, answerWord);

        final newRow = Guessrow(
          letters: List.from(currentGuess),
          matches: evaluated,
        );
        guesses.add(newRow);
        currentGuess.clear();

        if (settings.isSoundEnabled) SoundService.playClick();
        if (settings.isHapticEnabled) VibrationService.vibrate();

        for (int i = 0; i < evaluated.length; i++) {
          await Future.delayed(
            Duration(milliseconds: settings.isTileAnimationEnabled ? 100 : 0),
          );
          refreshUI();

          final letter = newRow.letters[i];
          final match = newRow.matches[i];
          final existing = keyColors[letter];
          if (existing == null || match.index > existing.index) {
            keyColors[letter] = match;
          }
          refreshUI();
        }

        final won = guessString == answerWord;
        final over = won || guesses.length >= 6;

        if (over) {
          final stats = context.read<StatsProvider>();
          final guessIndex = guesses.length - 1;

          if (isDailyMode && dailyWordLength != null) {
            debugPrint("📅 Daily mode - updating daily stats...");
            await stats.updateDailyStats(won: won, guessIndex: guessIndex);
            await DailyWordPlayedTracker().markPlayed(
              DateTime.now(),
              dailyWordLength!,
            );
          } else {
            debugPrint("📊 Regular mode - updating general stats...");
            await stats.incrementGame(won: won, guessCount: guessIndex + 1);
          }

          if (settings.isSoundEnabled) {
            won ? SoundService.playSuccess() : SoundService.playError();
          }
          if (settings.isHapticEnabled) {
            won
                ? VibrationService.vibrateSuccess()
                : VibrationService.vibrateError();
          }

          gameOver = true;

          await Future.delayed(
            Duration(
              milliseconds: settings.isTileAnimationEnabled
                  ? length * 100 + 200
                  : 300,
            ),
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              onGameOver?.call(won, answerWord);
            }
          });
        }

        isFlipping = false;
      }
    } else if (RegExp(r'^[A-Z]$').hasMatch(key) &&
        currentGuess.length < length) {
      currentGuess.add(key);
      if (settings.isSoundEnabled) SoundService.playClick();
      if (settings.isHapticEnabled) VibrationService.vibrate();
      refreshUI();
    }

    debugPrint(
      "✍️ Key: $key, currentGuess: ${currentGuess.join()}, maxLength: $length",
    );
  }

  List<LetterMatch> evaluateGuess(List<String> guess, String answer) {
    List<LetterMatch> result = List.filled(guess.length, LetterMatch.absent);
    List<bool> taken = List.filled(answer.length, false);

    for (int i = 0; i < guess.length; i++) {
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
}
