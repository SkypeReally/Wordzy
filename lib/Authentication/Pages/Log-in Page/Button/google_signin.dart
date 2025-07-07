import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : Image.asset('assets/pics/google_logo.png', height: 20, width: 20),
      label: Text(
        isLoading ? 'Signing in...' : 'Sign in with Google',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1,
      ),
    );
  }
}
