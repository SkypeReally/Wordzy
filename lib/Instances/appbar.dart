import 'package:flutter/material.dart';

AppBar buildWordleAppBar({
  required BuildContext context,
  required String title,
  VoidCallback? onBack,
  Widget? leading,
  List<Widget>? actions,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final Color appBarBg = isDark
      ? const Color(0xFF433F49) // slightly cleaner hex
      : const Color(0xFFC0BBBD);

  final Color appBarFg = isDark ? Colors.white : Colors.black;

  return AppBar(
    backgroundColor: appBarBg,
    foregroundColor: appBarFg,
    elevation: 0,
    centerTitle: true,
    leading:
        leading ??
        (onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
            : null),
    title: Text(
      title.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
    ),
    actions: actions,
  );
}
