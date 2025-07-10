// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Main/gamepage.dart';
import 'package:gmae_wordle/Provider/category_progress_provider.dart';
import 'package:gmae_wordle/Service/wordlist.dart';
import 'package:gmae_wordle/Instances/page_transition.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = WordListService.getAvailableCategories();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), centerTitle: true),
      body: categories.isEmpty
          ? const Center(child: Text("No categories found."))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final icon = _getIconForCategory(category);

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    try {
                      final progress = context.read<CategoryProgressProvider>();
                      final alreadyFound = progress.getFoundWords(category);

                      final word =
                          await WordListService.getRandomWordFromCategory(
                            category,
                            3,
                            8,
                            alreadyFound,
                          );

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        createSlideRoute(
                          PlayGamePage(
                            fixedWord: word,
                            category: category,
                            isDailyMode: false,
                          ),
                        ),
                      );
                    } catch (e) {
                      _showError(
                        context,
                        e.toString().contains("All words found")
                            ? "🎉 You've completed all words in $category!"
                            : "Error loading $category: $e",
                      );
                    }
                  },

                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category[0].toUpperCase() + category.substring(1),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'animals':
        return Icons.pets;
      case 'birds':
        return Icons.filter_hdr;
      case 'fruits':
        return Icons.apple;
      case 'countries':
        return Icons.public;
      case 'colors':
        return Icons.palette;
      default:
        return Icons.category;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
