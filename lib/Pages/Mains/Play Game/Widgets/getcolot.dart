import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';

Color getColorFromMatch(LetterMatch match) {
  switch (match) {
    case LetterMatch.correct:
      return const Color(0xFF6AAA64); // Wordle green
    case LetterMatch.present:
      return const Color(0xFFC9B458); // Wordle yellow
    case LetterMatch.absent:
      return const Color(0xFF787C7E); // Wordle grey
    case LetterMatch.none:
      return const Color(0xFFDEE1E9); // Light gray for empty/default tiles
  }
}
