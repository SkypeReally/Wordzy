import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Keyboard/keyboardui.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/Tile%20Grid/tile_grid.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/getcolot.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/game_controlle.dart';

class GameBoard extends StatelessWidget {
  final GameController controller;
  final int wordLength;
  final Future<void> Function(String key) onKeyPressed;

  const GameBoard({
    super.key,
    required this.controller,
    required this.wordLength,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isTileAnimationEnabled = context
        .watch<SettingsProvider>()
        .isTileAnimationEnabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Center(
                // ⬅️ keeps grid vertically centered within space
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: TileGrid(
                      guesses: controller.guesses,
                      currentGuess: controller.currentGuess,
                      wordLength: wordLength,
                      isTileAnimationEnabled: () => isTileAnimationEnabled,
                      getColorFromMatch: getColorFromMatch,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: WordleKeyboard(
                  onKeyPressed: onKeyPressed,
                  keyColors: controller.keyColors,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
