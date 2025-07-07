import 'package:flutter/material.dart';

class CurrentRowWidget extends StatelessWidget {
  final List<String> currentGuess;
  final int wordLength;
  final double size;
  final double spacing;

  const CurrentRowWidget({
    required this.currentGuess,
    required this.wordLength,
    required this.size,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (col) {
        final letter = col < currentGuess.length ? currentGuess[col] : '';
        return Container(
          margin: EdgeInsets.only(
            right: col < wordLength - 1 ? spacing : 0,
            bottom: 8,
          ),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }
}
