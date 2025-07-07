import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final EdgeInsets padding;

  const LoadingSpinner({
    super.key,
    this.size = 32.0,
    this.color,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
