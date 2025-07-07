import 'package:flutter/material.dart';
import 'package:gmae_wordle/Daily%20Word/Daily%20Selector/Core/dailyword_tile.dart';

class DailyWordGrid extends StatelessWidget {
  final Map<int, bool> playedMap;
  final List<int> wordLengths;
  final void Function(int length) onTileTap;

  const DailyWordGrid({
    super.key,
    required this.playedMap,
    required this.wordLengths,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 400 ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: wordLengths.map((length) {
        final played = playedMap[length] ?? false;
        return DailyWordTile(
          wordLength: length,
          played: played,
          onTap: () => onTileTap(length),
        );
      }).toList(),
    );
  }
}
