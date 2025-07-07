import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback toggle;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.toggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
          tooltip: obscureText ? 'Show Password' : 'Hide Password',
        ),
      ),
      keyboardType: TextInputType.visiblePassword,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: const [AutofillHints.password],
    );
  }
}
