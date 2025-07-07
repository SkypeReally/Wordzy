import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/already_played.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/exit_confirmation.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/game_board.dart';
import 'package:provider/provider.dart';

import 'package:gmae_wordle/Instances/appbar.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/game_controlle.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/keyevent_handler.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/endgame_dialog.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/instruction_dialog.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';

class PlayGamePage extends StatefulWidget {
  final String? fixedWord;
  final bool isDailyMode;
  final int? dailyWordLength;
  final int wordLength;

  const PlayGamePage({
    super.key,
    this.fixedWord,
    required this.wordLength,
    this.isDailyMode = false,
    this.dailyWordLength,
  });

  @override
  State<PlayGamePage> createState() => _PlayGamePageState();
}

class _PlayGamePageState extends State<PlayGamePage> {
  final FocusNode _focusNode = FocusNode();
  GameController? controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FocusManager.instance.primaryFocus?.unfocus();
      final newController = GameController(
        context: context,
        wordLength: widget.isDailyMode
            ? widget.dailyWordLength!
            : context.read<WordLengthProvider>().wordLength,
        isDailyMode: widget.isDailyMode,
        dailyWordLength: widget.dailyWordLength,
        fixedWord: widget.fixedWord,
        onGameOver: _onGameOver,
        onAlreadyPlayed: _showAlreadyPlayedDialog,
        refreshUI: _refreshUI,
      );

      debugPrint("🕹️ Initializing game...");
      await newController.initializeGame();
      debugPrint("✅ Game initialized");

      if (mounted) {
        setState(() => controller = newController);
      }
    });
  }

  void _onGameOver(bool won, String answer) {
    showEndGameDialog(
      context: context,
      won: won,
      answerWord: answer,
      isDailyMode: widget.isDailyMode,
      onNewGame: () async {
        if (controller != null) {
          await controller!.restartGame();
          setState(() {});
        }
      },
    );
  }

  void _showAlreadyPlayedDialog() {
    showAlreadyPlayedDialog(context);
  }

  void _refreshUI() {
    if (mounted) setState(() {});
  }

  void _handleKeyEvent(KeyEvent event) {
    handlePhysicalKeyEvent(
      event: event,
      context: context,
      onKeyPress: (key) async {
        if (controller == null) return;
        await controller!.handleKeyPress(key);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.isWordLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final wordLength = widget.isDailyMode
        ? widget.dailyWordLength!
        : context.watch<WordLengthProvider>().wordLength;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: buildWordleAppBar(
          context: context,
          title: "Play",
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => showExitConfirmation(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 32.0, top: 4.0),
              child: IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: 'How to play',
                onPressed: () => showInstructionsDialog(context),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: GameBoard(
            controller: controller!,
            wordLength: wordLength,
            onKeyPressed: (key) async {
              await controller!.handleKeyPress(key);
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
