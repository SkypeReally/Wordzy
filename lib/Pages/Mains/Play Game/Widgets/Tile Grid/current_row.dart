import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/getcolot.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/game_controlle.dart';

class CurrentRowWidget extends StatelessWidget {
  final List<String> currentGuess;
  final String answerWord;
  final int wordLength;
  final double size;
  final double spacing;
  final GameController controller;

  const CurrentRowWidget({
    super.key,
    required this.currentGuess,
    required this.answerWord,
    required this.wordLength,
    required this.size,
    required this.spacing,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (col) {
        final String letter = col < currentGuess.length
            ? currentGuess[col]
            : '';

        Color tileColor;
        if (col == controller.hintedIndex && letter.isNotEmpty) {
          final hintedMatch = controller.hintedMatch;
          tileColor = hintedMatch != null
              ? getColorFromMatch(hintedMatch)
              : (isDark ? Colors.white12 : Colors.black12);
        } else {
          tileColor = letter.isNotEmpty
              ? (isDark ? Colors.white12 : Colors.black12)
              : Colors.transparent;
        }

        final borderColor = Colors.grey.shade600;

        return Container(
          margin: EdgeInsets.only(
            right: col < wordLength - 1 ? spacing : 0,
            bottom: 8,
          ),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        );
      }),
    );
  }
}
