import 'package:flutter/material.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DailyWordEntry> archiveList = [
      DailyWordEntry(
        date: DateTime(2025, 7, 6),
        word: "CHAIR",
        won: true,
        length: 5,
      ),
      DailyWordEntry(
        date: DateTime(2025, 7, 5),
        word: "DREAM",
        won: false,
        length: 5,
      ),
      DailyWordEntry(
        date: DateTime(2025, 7, 4),
        word: "LIGHT",
        won: true,
        length: 5,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Archive")),
      body: ListView.builder(
        itemCount: archiveList.length,
        itemBuilder: (context, index) {
          final entry = archiveList[index];
          return ListTile(
            leading: Icon(
              entry.won ? Icons.check_circle : Icons.cancel,
              color: entry.won ? Colors.green : Colors.red,
            ),
            title: Text(
              "${entry.word} (${entry.length}-letter)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatDate(entry.date)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(entry.word),
                  content: const Text("Definition feature coming soon."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

class DailyWordEntry {
  final DateTime date;
  final String word;
  final bool won;
  final int length;

  DailyWordEntry({
    required this.date,
    required this.word,
    required this.won,
    required this.length,
  });
}
