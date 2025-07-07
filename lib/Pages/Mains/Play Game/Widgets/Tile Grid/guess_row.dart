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

  const GuessRowWidget({
    required this.guess,
    required this.row,
    required this.wordLength,
    required this.size,
    required this.spacing,
    required this.isTileAnimationEnabled,
    required this.getColorFromMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (col) {
        final letter = guess.letters[col];
        final match = guess.matches[col];
        final color = getColorFromMatch(match);

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
                    delay: Duration(milliseconds: col * 250),
                    size: size,
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
