import 'package:flutter/material.dart';
import '../Widget/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: RegisterForm(),
            ),
          ),
        ),
      ),
    );
  }
}
