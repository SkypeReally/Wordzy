import 'package:flutter/material.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:provider/provider.dart';

class WordLengthPage extends StatelessWidget {
  const WordLengthPage({super.key});

  static const List<int> _wordLengths = [3, 4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    final selectedLength = context.watch<WordLengthProvider>().wordLength;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Select Word Length")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            itemCount: _wordLengths.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final length = _wordLengths[index];
              final isSelected = length == selectedLength;

              return GestureDetector(
                onTap: () {
                  context.read<WordLengthProvider>().setWordLength(length);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '$length Letters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
