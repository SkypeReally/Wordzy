import 'package:flutter/material.dart';

void showAlreadyPlayedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Already Played'),
      content: const Text(
        'You have already played today\'s word for this length. Come back tomorrow!',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
