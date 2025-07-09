import 'package:flutter/material.dart';

class DefinitionPage extends StatelessWidget {
  final String word;
  final String? definition; // Can be null if not available

  const DefinitionPage({super.key, required this.word, this.definition});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(word),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: definition != null
            ? Text(definition!, style: const TextStyle(fontSize: 16))
            : const Text(
                "No definition found.",
                style: TextStyle(color: Colors.grey),
              ),
      ),
    );
  }
}
