import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Game%20Mechanics/lettermatch.dart';

class FlipTile extends StatefulWidget {
  final String letter;
  final LetterMatch match;
  final Duration delay;
  final double size;
  final VoidCallback? onCompleted; // ✅ NEW

  const FlipTile({
    super.key,
    required this.letter,
    required this.match,
    required this.delay,
    required this.size,
    this.onCompleted, // ✅ NEW
  });

  @override
  State<FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<FlipTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flip;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _flip = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call(); // ✅ Call after flip finishes
      }
    });

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.match) {
      case LetterMatch.correct:
        return Colors.green;
      case LetterMatch.present:
        return Colors.amber.shade700;
      case LetterMatch.absent:
        return const Color.fromARGB(255, 39, 87, 160);
      case LetterMatch.none:
        return const Color(0xFFDEE1E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flip,
      builder: (context, child) {
        final value = _flip.value;
        final isBack = value >= 0.5;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(value * pi);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: _buildTileFace(
                    letter: widget.letter,
                    color: _getColor(),
                    textColor: Colors.white,
                  ),
                )
              : _buildTileFace(
                  letter: widget.letter,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  textColor:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                ),
        );
      },
    );
  }

  Widget _buildTileFace({
    required String letter,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}
