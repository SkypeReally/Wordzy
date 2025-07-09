import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';

class HardModePage extends StatelessWidget {
  const HardModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Hard Mode")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Enable Hard Mode"),
              subtitle: const Text(
                "You must use revealed hints in future guesses.\n"
                "Disabling won't affect current games.",
              ),
              value: settings.hardMode,
              onChanged: settings.setHardMode,
            ),
            const SizedBox(height: 24),
            const Text(
              "How it works:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "In Hard Mode, once you learn that a letter is correct "
              "(green) or present (yellow), you must use it in the same position "
              "or somewhere in the next guess respectively.",
            ),
          ],
        ),
      ),
    );
  }
}
