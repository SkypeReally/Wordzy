import 'package:flutter/material.dart';

class WordGrid extends StatelessWidget {
  final int wordLength;

  const WordGrid({super.key, required this.wordLength});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 8.0;
        final double totalSpacing = spacing * (wordLength - 1);
        final double availableWidth =
            constraints.maxWidth - 32; // 16 padding each side
        double tileSize = (availableWidth - totalSpacing) / wordLength;

        tileSize = tileSize.clamp(36.0, 56.0); // Prevent too small/large

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(6, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(wordLength, (col) {
                return Container(
                  margin: EdgeInsets.only(
                    right: col < wordLength - 1 ? spacing : 0,
                    bottom: 8,
                  ),
                  width: tileSize,
                  height: tileSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }
}
