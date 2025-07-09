import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Main/gamepage.dart';
import 'package:gmae_wordle/Pages/Mains/Word%20Lenth/wordlength_page.dart';
import 'package:gmae_wordle/Util/debug_util.dart';
// import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Instances/page_transition.dart';

class MenuButtons extends StatelessWidget {
  const MenuButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMenuButton(
          context,
          label: 'Play Game',
          onTap: () => Navigator.of(context).push(
            createSlideRoute(
              const PlayGamePage(isDailyMode: false),
              useDelay: true,
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildMenuButton(
          context,
          label: 'Word Length',
          onTap: () => Navigator.of(
            context,
          ).push(createSlideRoute(const WordLengthPage())),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Reset Daily Word Played"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                await DebugUtils.clearDailyWordPlayedKeys();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Daily word state reset.")),
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.white : Colors.black;
    final fgColor = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: bgColor,
          foregroundColor: fgColor,
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label),
        ),
      ),
    );
  }
}
