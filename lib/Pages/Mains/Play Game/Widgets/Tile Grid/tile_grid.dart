import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/guessrow.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/Tile%20Grid/current_row.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/Tile%20Grid/empty_row.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/Tile%20Grid/guess_row.dart';

class TileGrid extends StatelessWidget {
  final List<Guessrow> guesses;
  final List<String> currentGuess;
  final int wordLength;
  final bool Function() isTileAnimationEnabled;
  final Color Function(LetterMatch match) getColorFromMatch;

  const TileGrid({
    super.key,
    required this.guesses,
    required this.currentGuess,
    required this.wordLength,
    required this.isTileAnimationEnabled,
    required this.getColorFromMatch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const maxRows = 6;
        const keyboardHeight = 240;
        const reservedSpace = 160;

        final screenHeight = MediaQuery.of(context).size.height;
        final availableHeight = screenHeight - keyboardHeight - reservedSpace;
        final maxTileHeight = (availableHeight - (spacing * maxRows)) / maxRows;
        final availableWidth = constraints.maxWidth;
        final totalSpacing = spacing * (wordLength - 1);
        final tileWidth = (availableWidth - totalSpacing - 32) / wordLength;

        final tileSize = tileWidth.clamp(36.0, maxTileHeight.clamp(32.0, 56.0));

        return Column(
          children: List.generate(maxRows, (row) {
            if (row < guesses.length) {
              return GuessRowWidget(
                guess: guesses[row],
                row: row,
                wordLength: wordLength,
                size: tileSize,
                spacing: spacing,
                isTileAnimationEnabled: isTileAnimationEnabled,
                getColorFromMatch: getColorFromMatch,
              );
            } else if (row == guesses.length) {
              return CurrentRowWidget(
                currentGuess: currentGuess,
                wordLength: wordLength,
                size: tileSize,
                spacing: spacing,
              );
            } else {
              return EmptyRowWidget(
                wordLength: wordLength,
                size: tileSize,
                spacing: spacing,
              );
            }
          }),
        );
      },
    );
  }
}
