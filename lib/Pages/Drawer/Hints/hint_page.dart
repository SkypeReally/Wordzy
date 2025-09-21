import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';

class HintsPage extends StatelessWidget {
  const HintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'How hints work',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text(
                    'Hint System',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  content: const Text(
                    'You can use one of three hint types:\n\n'
                    '• Green: Reveals correct letter in correct position.\n'
                    '• Yellow: Correct letter, wrong spot.\n'
                    '• Grey: Marks unused letter.\n\n'
                    'Only available in normal mode.',
                    style: TextStyle(fontFamily: 'PulpFiction'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: settings.hintsEnabled,
              onChanged: settings.hardMode
                  ? null
                  : (enabled) => settings.setHintsEnabled(enabled),
              title: const Text(
                "Enable Hints",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                settings.hardMode
                    ? "Hints are disabled while Hard Mode is active."
                    : "Allow hints during normal mode (not daily or hard mode).",
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
              title: Text(
                "Green Hint",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Reveals a correct letter in the correct spot."),
            ),
            const ListTile(
              leading: Icon(Icons.warning_amber, color: Colors.amber),
              title: Text(
                "Yellow Hint",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Reveals a correct letter in the wrong spot."),
            ),
            const ListTile(
              leading: Icon(Icons.block, color: Colors.grey),
              title: Text(
                "Grey Hint",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Marks a letter not in the word."),
            ),
            const SizedBox(height: 24),
            if (settings.hardMode)
              const ListTile(
                leading: Icon(Icons.lock, color: Colors.redAccent),
                title: Text("Hard Mode Active"),
                subtitle: Text(
                  "Hints are automatically disabled in Hard Mode.",
                ),
              ),
          ],
        ),
      ),
    );
  }
}
