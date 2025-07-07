import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';

typedef OnKeyPressCallback = Future<void> Function(String key);

void handlePhysicalKeyEvent({
  required KeyEvent event,
  required BuildContext context,
  required OnKeyPressCallback onKeyPress,
}) {
  if (event is! KeyDownEvent) return;

  final settings = context.read<SettingsProvider>();
  if (!settings.isPhysicalKeyboardEnabled) return;

  final String rawKey = event.logicalKey.keyLabel.trim().toUpperCase();

  switch (rawKey) {
    case 'BACKSPACE':
      onKeyPress('⌫');
      break;
    case 'ENTER':
      onKeyPress('ENTER');
      break;
    default:
      if (RegExp(r'^[A-Z]$').hasMatch(rawKey)) {
        onKeyPress(rawKey);
      } else {
        debugPrint(
          '❗ Unhandled physical key: "$rawKey" (${event.logicalKey.keyId})',
        );
      }
      break;
  }
}
