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
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontFamily: 'ModernFeeling',
            fontWeight: FontWeight.w900,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
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
                  child: Consumer<CategoryProgressProvider>(
                    builder: (context, progressProvider, _) {
                      final progress = progressProvider.getCategoryProgress(
                        category,
                      );
                      final isComplete = progress >= 1.0;
                      final badgePath = _badgeIconPathFor(progress);
                      final foundCount = progressProvider.getFoundCount(
                        category,
                      );
                      final totalCount = WordListService.getWordsFromCategory(
                        category,
                      ).length;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? Colors.green.withOpacity(0.15)
                              : Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: isComplete
                              ? Border.all(color: Colors.green, width: 2)
                              : null,
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
                            Tooltip(
                              message: '${(progress * 100).toInt()}% complete',
                              child: Image.asset(
                                badgePath,
                                width: 36,
                                height: 36,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$foundCount / $totalCount",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category[0].toUpperCase() + category.substring(1),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  String _badgeIconPathFor(double progress) {
    if (progress >= 1.0) return 'assets/pics/badges/diamond_badge.png';
    if (progress >= 0.75) return 'assets/pics/badges/gold_badge.png';
    if (progress >= 0.5) return 'assets/pics/badges/silver_badge.png';
    if (progress > 0.0) return 'assets/pics/badges/bronze_badge.png';
    return 'assets/pics/badges/bronze_badge.png';
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
