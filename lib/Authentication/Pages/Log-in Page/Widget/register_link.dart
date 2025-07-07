import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Authentication/Pages/Register%20Page/Main/register.dart';

class RegisterLink extends StatelessWidget {
  const RegisterLink({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            color: theme.textTheme.bodyLarge?.color,
          ),
          children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: "Register",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.none,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
