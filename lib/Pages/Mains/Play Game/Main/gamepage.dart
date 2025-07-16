import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Instances/page_transition.dart';
import 'package:gmae_wordle/Provider/category_progress_provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/Service/wordlist.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/game_controlle.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Logic/keyevent_handler.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/already_played.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/endgame_dialog.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/exit_confirmation.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Dialog/instruction_dialog.dart';
import 'package:gmae_wordle/Pages/Mains/Play%20Game/Widgets/game_board.dart';
import 'package:gmae_wordle/Instances/appbar.dart';

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
    _focusNode.requestFocus();
  }

  Future<void> _initController() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final wordLengthProvider = context.read<WordLengthProvider>();

    int wordLength;

    if (widget.fixedWord != null && widget.fixedWord!.isNotEmpty) {
      wordLength = widget.fixedWord!.length;
    } else if (widget.isDailyMode) {
      wordLength = widget.dailyWordLength!;
    } else {
      if (!wordLengthProvider.isInitialized) return;
      wordLength = wordLengthProvider.wordLength;
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
    if (mounted) setState(() => controller = newController);
  }

  void _onGameOver(bool won, String answer) {
    final isCategoryMode = widget.category != null;

    if (isCategoryMode && won) {
      final categoryProvider = context.read<CategoryProgressProvider>();

      categoryProvider
          .markWordFoundAndCheckBadge(widget.category!, answer)
          .then((badgeUpgraded) async {
            if (badgeUpgraded) {
              await Future.delayed(const Duration(milliseconds: 300));
              if (context.mounted) {
                _showBadgeUpgradeDialog(
                  widget.category!,
                  categoryProvider.getBadge(widget.category!),
                );
              }
            }

            // Show end game after badge dialog
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) _showEndDialog(won, answer);
            });
          });
    } else {
      _showEndDialog(won, answer);
    }
  }

  void _showEndDialog(bool won, String answer) {
    final isCategoryMode = widget.category != null;

    showEndGameDialog(
      context: context,
      won: won,
      answerWord: isCategoryMode && !won ? null : answer,
      isDailyMode: widget.isDailyMode,
      category: widget.category,
      onNewGame: () async {
        if (isCategoryMode) {
          final progress = context.read<CategoryProgressProvider>();
          final alreadyFound = progress.getFoundWords(widget.category!);
          alreadyFound.add(answer.toUpperCase());

          try {
            final newWord = await WordListService.getRandomWordFromCategory(
              widget.category!,
              3,
              8,
              alreadyFound,
            );

            if (!context.mounted) return;

            Navigator.pushReplacement(
              context,
              createSlideRoute(
                PlayGamePage(fixedWord: newWord, category: widget.category!),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No new words left in this category!")),
            );
          }
        } else {
          await controller?.restartGame();
          if (mounted) setState(() {});
        }
      },
    );
  }

  void _showBadgeUpgradeDialog(String category, String badge) {
    final iconPath = _badgeIconPathFor(badge);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Badge Upgraded",
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.7),
          body: Center(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "🎉 New Badge Earned!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Image.asset(iconPath, width: 72, height: 72),
                        const SizedBox(height: 16),
                        Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "in the \"$category\" category",
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("Continue"),
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _badgeIconPathFor(String badge) {
    switch (badge.toLowerCase()) {
      case '🥉 bronze':
        return 'assets/pics/badges/bronze_badge.png';
      case '🥈 silver':
        return 'assets/pics/badges/silver_badge.png';
      case '🥇 gold':
        return 'assets/pics/badges/gold_badge.png';
      case '💎 diamond':
        return 'assets/pics/badges/diamond_badge.png';
      default:
        return 'assets/pics/badges/bronze_badge.png';
    }
  }

  void _showAlreadyPlayedDialog() => showAlreadyPlayedDialog(context);

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

    if (controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller == null) _initController();
      });
    }

    if (controller == null || !controller!.isWordLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = context.watch<SettingsProvider>();
    final wordLength = controller!.wordLength;

    final bool showHints =
        !widget.isDailyMode &&
        settings.hintsEnabled &&
        !settings.hardMode &&
        !(controller?.hasUsedHint ?? true);

    final String pageTitle = widget.category != null
        ? widget.category!
        : widget.isDailyMode
        ? 'Daily Word'
        : 'Play';

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
                const Icon(Icons.lock, size: 20, color: Colors.redAccent),
              if (settings.hintsEnabled)
                const Icon(
                  Icons.tips_and_updates,
                  size: 20,
                  color: Colors.blueAccent,
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
