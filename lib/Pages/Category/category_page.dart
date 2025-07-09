import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Main/gamepage.dart';
import 'package:gmae_wordle/Service/wordlist.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'Animals',
      'Birds',
      'Fruits',
      'Countries',
      'Colors',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final category = categories[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: Text(category),
              onTap: () async {
                final words = WordListService.getWordsFromCategory(category);
                if (words.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No words found in $category')),
                  );
                  return;
                }

                final randomWord = words[Random().nextInt(words.length)];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayGamePage(
                      fixedWord: randomWord,
                      category: category,
                      isDailyMode: false,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
