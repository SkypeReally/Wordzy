import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String? error;

  const ErrorMessage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        error!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
