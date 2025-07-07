import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Button/email_signin.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Button/forgot_password.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Button/google_signin.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Button/guest_signin.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Dialog/error_message_display.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Widget/emai_textfield.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Widget/loading_spinner.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Widget/password_testfield.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Widget/register_link.dart';
import 'package:gmae_wordle/Authentication/Core/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? error;
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // No need for display name or snackbar here — AuthWrapper handles it.
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = "Unexpected error occurred");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await _authService.signInWithGoogle(context);
      // AuthWrapper handles display name sync and cloud sync
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      print("Unexpected Google sign-in error: $e");
      setState(() => error = "Unexpected error occurred");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signInAnonymously() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await _authService.signInAnonymously(context);
      // Display name is handled in AuthService and synced in AuthWrapper
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => error = e.message);
      }
    } catch (e) {
      print("Unexpected anonymous login error: $e");
      if (mounted) {
        setState(() => error = "Unexpected error occurred");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email to reset password"),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to send reset email")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Sign In")),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "👋 Welcome to Wordzy!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Play daily puzzles and sharpen your mind.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                if (error != null) ErrorMessage(error!),

                EmailField(controller: _emailController),
                const SizedBox(height: 10),
                PasswordField(
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  toggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),

                ForgotPasswordButton(
                  isLoading: isLoading,
                  onPressed: _resetPassword,
                ),

                const SizedBox(height: 20),
                EmailSignInButton(
                  isLoading: isLoading,
                  onPressed: _signInWithEmail,
                ),
                const SizedBox(height: 10),
                GoogleSignInButton(
                  isLoading: isLoading,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 12),
                GuestSignInButton(
                  isLoading: isLoading,
                  onPressed: _signInAnonymously,
                ),

                if (isLoading) const LoadingSpinner(),

                const SizedBox(height: 30),
                const RegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
