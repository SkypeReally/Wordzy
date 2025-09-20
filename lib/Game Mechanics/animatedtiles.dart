import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedTile extends StatefulWidget {
  final String letter;
  final Color color;
  final double size;
  final Duration delay;

  const AnimatedTile({
    super.key,
    required this.letter,
    required this.color,
    required this.size,
    required this.delay,
  });

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isBack = _flipAnimation.value >= pi / 2;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_flipAnimation.value);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: isBack ? _buildBackTile() : _buildFrontTile(),
        );
      },
    );
  }

  Widget _buildFrontTile() {
    return _tileContainer(
      color: Colors.white,
      borderColor: Colors.grey,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildBackTile() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationX(pi),
      child: _tileContainer(
        color: widget.color,
        borderColor: Colors.grey.shade300,
        child: Text(
          widget.letter,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _tileContainer({
    required Color color,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}
