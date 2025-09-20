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

  final logicalKey = event.logicalKey;
  String? key = logicalKey.keyLabel;

  if (key.isEmpty) {
    final debugName = logicalKey.debugName ?? '';
    final match = RegExp(
      r'^Key ([A-Z])$',
      caseSensitive: false,
    ).firstMatch(debugName);
    if (match != null) {
      key = match.group(1)!;
    }
  }

  key = key.trim().toUpperCase();

  if (key == 'ENTER') {
    onKeyPress('ENTER');
  } else if (key == 'BACKSPACE') {
    onKeyPress('⌫');
  } else if (RegExp(r'^[A-Z]$').hasMatch(key)) {
    onKeyPress(key);
  } else {
    debugPrint(
      '❗ Unhandled physical key: "${logicalKey.debugName}" (${logicalKey.keyId})',
    );
  }
}
