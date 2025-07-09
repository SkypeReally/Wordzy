import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';

class HintsPage extends StatelessWidget {
  const HintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hints')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: settings.hintsEnabled,
              onChanged: (enabled) => settings.setHintsEnabled(enabled),
              title: const Text("Enable Hints"),
              subtitle: const Text(
                "Allow hints during normal mode (not daily or hard mode).",
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "How Hints Work",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Green Hint"),
              subtitle: Text("Reveals a correct letter in the correct spot."),
            ),
            const ListTile(
              leading: Icon(Icons.warning_amber, color: Colors.amber),
              title: Text("Yellow Hint"),
              subtitle: Text("Reveals a correct letter in the wrong spot."),
            ),
            const ListTile(
              leading: Icon(Icons.block, color: Colors.grey),
              title: Text("Grey Hint"),
              subtitle: Text("Marks a letter not in the word."),
            ),
            const SizedBox(height: 24),
            if (settings.hardMode)
              const Text(
                "Hints are disabled in Hard Mode.",
                style: TextStyle(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}
