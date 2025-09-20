import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginLink extends StatelessWidget {
  final VoidCallback onTap;

  const LoginLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
          children: [
            const TextSpan(text: "Already have an account? "),
            TextSpan(
              text: "Log In",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
