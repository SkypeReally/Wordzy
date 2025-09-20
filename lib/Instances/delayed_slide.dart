import 'package:flutter/material.dart';

class DelayedSlidePage extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  const DelayedSlidePage({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 130),
    this.duration = const Duration(milliseconds: 400),
    this.beginOffset = const Offset(1.0, 0),
  });

  @override
  State<DelayedSlidePage> createState() => _DelayedSlidePageState();
}

class _DelayedSlidePageState extends State<DelayedSlidePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _offsetAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
    return SlideTransition(position: _offsetAnimation, child: widget.child);
  }
}
