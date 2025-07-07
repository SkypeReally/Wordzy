import 'package:flutter/material.dart';

class ForgotPasswordButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const ForgotPasswordButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isLoading
                ? Colors.grey
                : Theme.of(context).colorScheme.primary,
          ),
          child: const Text(
            "Forgot Password?",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
