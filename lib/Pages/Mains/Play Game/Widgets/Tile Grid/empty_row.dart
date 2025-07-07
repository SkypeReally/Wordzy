import 'package:flutter/material.dart';

class EmptyRowWidget extends StatelessWidget {
  final int wordLength;
  final double size;
  final double spacing;

  const EmptyRowWidget({
    required this.wordLength,
    required this.size,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (col) {
        return Container(
          margin: EdgeInsets.only(
            right: col < wordLength - 1 ? spacing : 0,
            bottom: 8,
          ),
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
