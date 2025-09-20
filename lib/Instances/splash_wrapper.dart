import 'package:flutter/material.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Service/dailyword_service.dart';
import 'package:gmae_wordle/Service/wordlist.dart';

class SplashWrapper extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final SettingsProvider settingsProvider;

  const SplashWrapper({
    super.key,
    required this.builder,
    required this.settingsProvider,
  });

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _isReady = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await widget.settingsProvider.loadSettings();

      await WordListService.loadWordList();
      await DailyWordService.loadDailyWords();

      setState(() {
        _isReady = true;
      });
    } catch (e, st) {
      debugPrint('❌ SplashWrapper init error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return widget.builder(context);
  }
}
