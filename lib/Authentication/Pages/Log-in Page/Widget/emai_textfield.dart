import 'package:flutter/material.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Widget/auth_textfield.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: "Email",
      hintText: "Enter your email",
      keyboardType: TextInputType.emailAddress,
      capitalization: TextCapitalization.none,
    );
  }
}
