import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';

Color getColorFromMatch(LetterMatch match) {
  switch (match) {
    case LetterMatch.correct:
      return const Color(0xFF6AAA64);
    case LetterMatch.present:
      return const Color(0xFFC9B458);
    case LetterMatch.absent:
      return const Color.fromARGB(255, 31, 138, 192);
    case LetterMatch.none:
      return Colors.transparent;
  }
}
