import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Pages/Mains/Daily%20Word/Widget/dailycountdown.dart';
import 'package:gmae_wordle/Pages/Mains/Daily%20Word/Widget/dailytile.dart';
import 'package:gmae_wordle/Pages/Mains/Daily%20Word/Widget/startchallengeui.dart';

class DailyWordPage extends StatefulWidget {
  const DailyWordPage({super.key});

  @override
  State<DailyWordPage> createState() => _DailyWordPageState();
}

class _DailyWordPageState extends State<DailyWordPage> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTimeLeft(),
    );
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final diff = nextMidnight.difference(now);

    if (mounted) {
      setState(() => _timeLeft = diff);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Word"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DailyTitleSection(),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1A000000),

                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Daily Word",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Take on today's challenge with a word length of your choice.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),

                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const StartChallengeButton(),
                    const SizedBox(height: 12),
                    DailyCountdownCard(timeLeft: _timeLeft),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
