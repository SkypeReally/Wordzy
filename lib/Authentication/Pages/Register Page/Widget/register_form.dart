import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Authentication/Pages/Register%20Page/Dialog/error_message.dart';
import 'package:gmae_wordle/Authentication/Pages/Register%20Page/Widget/password_field.dart';
import 'package:gmae_wordle/Authentication/Pages/Register%20Page/Button/register_button.dart';
import 'package:gmae_wordle/Authentication/Pages/Register%20Page/Widget/terms_checkbox.dart';
import 'package:gmae_wordle/Authentication/Pages/Register%20Page/Widget/login_link.dart';
import '../../../../Provider/setting_provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final ctx = context;
    final settingsProvider = Provider.of<SettingsProvider>(ctx, listen: false);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text("You must agree to the terms.")),
      );
      return;
    }

    if (password.length < 6) {
      setState(() => error = "Password must be at least 6 characters.");
      return;
    }

    if (password != confirm) {
      setState(() => error = "Passwords do not match.");
      return;
    }

    setState(() {
      error = null;
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user != null) {
        if (name.isNotEmpty) {
          await user.updateDisplayName(name);
          await user.reload();
          settingsProvider.setDisplayName(name);
        } else if (user.displayName?.isNotEmpty ?? false) {
          settingsProvider.setDisplayName(user.displayName!.split(" ").first);
        } else {
          settingsProvider.setDisplayName("Player");
        }
      }

      if (!mounted) return;
      Navigator.pop(ctx);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text("Account created. Please sign in.")),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          const Text(
            "📝 Welcome to Wordzy!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "Create an account to save stats and enjoy daily puzzles.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          if (error != null) ErrorMessage(error: error),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Profile Name (optional)",
            ),
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 10),

          PasswordField(
            controller: _passwordController,
            label: "Password",
            obscureText: _obscurePassword,
            toggle: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 10),

          PasswordField(
            controller: _confirmPasswordController,
            label: "Confirm Password",
            obscureText: _obscureConfirmPassword,
            toggle: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),

          const SizedBox(height: 10),
          TermsCheckbox(
            value: _agreeToTerms,
            onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
          ),

          const SizedBox(height: 20),
          RegisterButton(isLoading: isLoading, onPressed: _register),
          const SizedBox(height: 20),
          LoginLink(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
