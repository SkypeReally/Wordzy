import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';

Color getColorFromMatch(LetterMatch match) {
  switch (match) {
    case LetterMatch.correct:
      return const Color(0xFF6AAA64); // green
    case LetterMatch.present:
      return const Color(0xFFC9B458); // yellow
    case LetterMatch.absent:
      return const Color(0xFF787C7E); // grey
    case LetterMatch.none:
      return Colors.transparent; // ✅ no veil
  }
}
