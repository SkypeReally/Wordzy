import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
          children: [
            const TextSpan(text: "I agree to the "),
            TextSpan(
              text: "Terms & Conditions",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none, // 🔒 no underline
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Terms & Conditions"),
                      content: const Text(
                        "This game is for entertainment purposes only. "
                        "By registering, you agree to our terms. "
                        "You must be at least 1 second old to play.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
    );
  }
}
