import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:gmae_wordle/Authentication/Core/auth_wrapper.dart';
import 'package:gmae_wordle/Daily%20Word/Daily%20Selector/Main/dailyword_selector.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Main/settingspage.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Main/statspage.dart';
import 'package:gmae_wordle/Pages/Mains/Daily%20Word/Main/dailyword_page.dart';
import 'package:gmae_wordle/Pages/Mains/Word%20Lenth/wordlength_page.dart';

import 'package:gmae_wordle/Preferences/theme_data.dart';
import 'package:gmae_wordle/Util/firebase_options.dart';

import 'package:gmae_wordle/Provider/theme_provider.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Provider/dailystats_provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';

import 'package:gmae_wordle/Service/wordlist.dart';
import 'package:gmae_wordle/Service/dailyword_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  await WordListService.loadWordList();
  await DailyWordService.loadDailyWords();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WordLengthProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => DailyStatsProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle Game',
      theme: customLightTheme,
      darkTheme: customDarkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
      routes: {
        '/daily': (_) => const DailyWordPage(),
        '/wordlength': (_) => const WordLengthPage(),
        '/stats': (_) => const StatsPage(),
        '/settings': (_) => const SettingsPage(),
        '/dailyplay': (_) => const DailyWordLengthSelectorPage(),
      },
    );
  }
}
