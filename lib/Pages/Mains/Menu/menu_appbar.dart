import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/theme_provider.dart';

class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MenuAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark
        ? const Color.fromARGB(255, 67, 63, 73)
        : const Color.fromARGB(255, 192, 187, 187);
    final fgColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      centerTitle: true,
      title: const Text(
        'Wordle',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
    );
  }
}
