import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextCapitalization capitalization;
  final TextInputType keyboardType;
  final String? hintText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.capitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textCapitalization: capitalization,
        keyboardType: keyboardType,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
