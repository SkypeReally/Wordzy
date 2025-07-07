import 'package:flutter/material.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Widget/auth_textfield.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback toggle;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.toggle,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: "Password",
      hintText: "Enter your password",
      obscureText: obscure,
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: toggle,
      ),
    );
  }
}
