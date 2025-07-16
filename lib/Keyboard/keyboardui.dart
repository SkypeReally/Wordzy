import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';

class WordleKeyboard extends StatelessWidget {
  final void Function(String key) onKeyPressed;
  final Map<String, LetterMatch> keyColors;

  const WordleKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.keyColors,
  });

  static const row1 = 'QWERTYUIOP';
  static const row2 = 'ASDFGHJKL';
  static const row3 = 'ZXCVBNM';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = 4.0;
    final padding = 1.5;
    final keyWidth = ((screenWidth - 20 - spacing * 9) / 10).clamp(30.0, 48.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, row1.split(''), keyWidth, spacing, padding),
        const SizedBox(height: 5),
        _buildRow(
          context,
          row2.split(''),
          keyWidth,
          spacing,
          padding,
          horizontalMargin: keyWidth / 2,
        ),
        const SizedBox(height: 5),
        _buildRow(
          context,
          [...row3.split(''), '⌫'],
          keyWidth,
          spacing,
          padding,
        ),
        const SizedBox(height: 8),
        _buildRow(
          context,
          ['ENTER'],
          keyWidth,
          spacing,
          padding,
          centerOnly: true,
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<String> keys,
    double keyWidth,
    double spacing,
    double padding, {
    double horizontalMargin = 0,
    bool centerOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys.map((key) {
          double width = keyWidth;
          if (key == 'ENTER') width *= 3.9;
          if (key == '⌫') width *= 1.2;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: _buildKey(context, key, width),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKey(BuildContext context, String key, double width) {
    return SizedBox(
      width: width,
      height: 48,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _getKeyColor(context, key),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ExcludeFocus(
          child: TextButton(
            onPressed: () => onKeyPressed(key),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getKeyColor(BuildContext context, String key) {
    final match = keyColors[key];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (match) {
      LetterMatch.correct =>
        isDark ? const Color(0xFF538D4E) : const Color(0xFF6AAA64),
      LetterMatch.present =>
        isDark ? const Color(0xFFB59F3B) : const Color(0xFFC9B458),
      LetterMatch.absent =>
        isDark
            ? const Color.fromARGB(255, 39, 87, 160)
            : const Color(0xFF787C7E),
      _ => isDark ? const Color(0xFF818384) : const Color(0xFFD3D6DA),
    };
  }
}
