import 'lettermatch.dart';

class Guessrow {
  final List<String> letters;
  final List<LetterMatch> matches;
  bool isRevealed;

  Guessrow({
    required this.letters,
    required this.matches,
    this.isRevealed = false,
  }) : assert(
         letters.length == matches.length,
         'Letters and matches length must be equal.',
       );

  @override
  String toString() =>
      'Guessrow(letters: $letters, matches: $matches, isRevealed: $isRevealed)';
}
