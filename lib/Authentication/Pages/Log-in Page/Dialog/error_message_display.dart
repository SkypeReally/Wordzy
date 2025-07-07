import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  const ErrorMessage(
    this.message, {
    super.key,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style:
            style ??
            const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
