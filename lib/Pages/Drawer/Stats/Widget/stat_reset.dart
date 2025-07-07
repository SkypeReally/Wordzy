import 'package:flutter/material.dart';

class StatsResetButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const StatsResetButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
