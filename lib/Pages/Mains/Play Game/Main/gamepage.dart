import 'package:flutter/material.dart';
import 'package:gmae_wordle/Provider/category_progress_provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:provider/provider.dart';

import 'package:gmae_wordle/Instances/appbar.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/game_controlle.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/keyevent_handler.dart';

import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/already_played.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/endgame_dialog.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/exit_confirmation.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/instruction_dialog.dart';

import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/game_board.dart';

class PlayGamePage extends StatefulWidget {
  final String? fixedWord;
  final bool isDailyMode;
  final int? dailyWordLength;
  final String? category;

  const PlayGamePage({
    super.key,
    this.fixedWord,
    this.isDailyMode = false,
    this.dailyWordLength,
    this.category,
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
    // ❌ Don't call _initController here; wait for provider init in build
  }

  Future<void> _initController() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final wordLengthProvider = context.read<WordLengthProvider>();

    int wordLength;

    if (widget.fixedWord != null && widget.fixedWord!.isNotEmpty) {
      wordLength = widget.fixedWord!.length;

      debugPrint(
        "📌 Using fixedWord: ${widget.fixedWord}, length: $wordLength",
      );
      // ⚠️ Do NOT call wordLengthProvider.setWordLength() here
    } else if (widget.isDailyMode) {
      wordLength = widget.dailyWordLength!;
      debugPrint("📅 Daily mode: word length = $wordLength");
    } else {
      if (!wordLengthProvider.isInitialized) {
        debugPrint("⏳ WordLengthProvider not ready yet. Delaying init.");
        return;
      }
      wordLength = wordLengthProvider.wordLength;
      debugPrint("🕹️ Normal mode: word length from provider = $wordLength");
    }

    final newController = GameController(
      context: context,
      wordLength: wordLength,
      isDailyMode: widget.isDailyMode,
      dailyWordLength: widget.dailyWordLength,
      fixedWord: widget.fixedWord,
      category: widget.category,
      onGameOver: _onGameOver,
      onAlreadyPlayed: _showAlreadyPlayedDialog,
      refreshUI: _refreshUI,
    );

    await newController.initializeGame();

    if (mounted) {
      setState(() => controller = newController);

      debugPrint("✅ GameController initialized");
      debugPrint("📏 Provider wordLength = ${wordLengthProvider.wordLength}");
      debugPrint("📏 Controller wordLength = ${newController.wordLength}");
    }
  }

  void _onGameOver(bool won, String answer) {
    final isCategoryMode = widget.category != null;

    if (isCategoryMode && won) {
      final categoryProvider = context.read<CategoryProgressProvider>();
      categoryProvider.markWordFound(widget.category!, answer);
    }

    showEndGameDialog(
      context: context,
      won: won,
      answerWord: isCategoryMode && !won
          ? null
          : answer, // ✅ Hide answer if lost in category
      isDailyMode: widget.isDailyMode,
      category: widget.category,
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
        if (mounted) setState(() {});
      },
    );
  }

  void _handleHintPress() {
    if (controller == null) return;
    controller!.useHint();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final wordLengthProvider = context.watch<WordLengthProvider>();

    if (!widget.isDailyMode && !wordLengthProvider.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🛠 Trigger init after wordLengthProvider is ready
    if (controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller == null) {
          _initController();
        }
      });
    }

    if (controller == null || !controller!.isWordLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = context.watch<SettingsProvider>();

    final String pageTitle = widget.category != null
        ? '${widget.category}'
        : widget.isDailyMode
        ? 'Daily Word'
        : 'Play';

    final bool showHints =
        !widget.isDailyMode &&
        settings.hintsEnabled &&
        !settings.hardMode &&
        !(controller?.hasUsedHint ?? true);

    final wordLength = controller!.wordLength;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: buildWordleAppBar(
          context: context,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pageTitle.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              if (settings.hardMode)
                Tooltip(
                  message: "Hard Mode Enabled",
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You are in Hard Mode."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.lock,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              if (settings.hintsEnabled)
                Tooltip(
                  message: "Hints Enabled",
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Hints are active for this game."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.tips_and_updates,
                      size: 20,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => showExitConfirmation(context),
          ),
          actions: [
            if (showHints)
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                tooltip: 'Use Hint',
                onPressed: _handleHintPress,
              ),
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
              if (mounted) setState(() {});
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
