import 'package:flutter/material.dart';

class GuestSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GuestSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : const Icon(Icons.person_outline),
      label: Text(
        isLoading ? "Loading..." : "Continue as Guest",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1,
      ),
    );
  }
}
