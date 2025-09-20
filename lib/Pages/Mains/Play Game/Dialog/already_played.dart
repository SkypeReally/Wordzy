import 'package:flutter/material.dart';

void showAlreadyPlayedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Already Played Today",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        "You can only play the Daily Word once per day.\nCome back tomorrow for a new one!",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
          child: const Text(
            "OK",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
