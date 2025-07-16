import 'package:flutter/material.dart';

class FadeMessageWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onFadeComplete;
  final bool isDarkMode;

  const FadeMessageWidget({
    Key? key,
    required this.message,
    this.onFadeComplete,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _FadeMessageWidgetState createState() => _FadeMessageWidgetState();
}

class _FadeMessageWidgetState extends State<FadeMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _controller.reverse();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onFadeComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors based on theme mode
    final backgroundColor = widget.isDarkMode
        ? const Color.fromARGB(217, 12, 11, 11) // approx 85% opacity blackish
        : const Color.fromARGB(206, 196, 191, 191); // approx 70% opacity white

    final textColor = widget.isDarkMode
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 0, 0, 0);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),

        child: SizedBox(
          width: 335, // increase width as needed
          height: 80, // increase height as needed
          child: Center(
            child: Text(
              widget.message,
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
