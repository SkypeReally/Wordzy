import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/fliptile.dart';
import 'package:gmae_wordle/Game%20Mechanics/guessrow.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';

class GuessRowWidget extends StatelessWidget {
  final Guessrow guess;
  final int row;
  final int wordLength;
  final double size;
  final double spacing;
  final bool Function() isTileAnimationEnabled;
  final Color Function(LetterMatch match) getColorFromMatch;
  final VoidCallback? onFlipComplete;
  final bool isLastGuessRow;

  const GuessRowWidget({
    super.key,
    required this.guess,
    required this.row,
    required this.wordLength,
    required this.size,
    required this.spacing,
    required this.isTileAnimationEnabled,
    required this.getColorFromMatch,
    this.onFlipComplete,
    this.isLastGuessRow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (col) {
        final letter = guess.letters[col];
        final match = guess.matches[col];
        final color = getColorFromMatch(match);

        final isLastTile = col == wordLength - 1;
        final delay = Duration(milliseconds: col * 250);

        return Padding(
          padding: EdgeInsets.only(
            right: col < wordLength - 1 ? spacing : 0,
            bottom: 8,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: isTileAnimationEnabled()
                ? FlipTile(
                    key: ValueKey('${row}_${col}_$letter'),
                    letter: letter,
                    match: match,
                    delay: delay,
                    size: size,
                    onCompleted: isLastTile && isLastGuessRow
                        ? onFlipComplete
                        : null,
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
