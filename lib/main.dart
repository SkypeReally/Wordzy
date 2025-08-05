import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Instances/splash_wrapper.dart';
import 'package:gmae_wordle/Authentication/Core/auth_wrapper.dart';
import 'package:gmae_wordle/Pages/Drawer/Settings/Main/settingspage.dart';
import 'package:gmae_wordle/Pages/Drawer/Stats/Main/statspage.dart';
import 'package:gmae_wordle/Pages/Mains/Daily%20Word/Main/dailyword_page.dart';
import 'package:gmae_wordle/Pages/Mains/Word%20Lenth/wordlength_page.dart';
import 'package:gmae_wordle/Daily%20Word/Daily%20Selector/Main/dailyword_selector.dart';
import 'package:gmae_wordle/Provider/theme_provider.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Provider/dailystats_provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/streak_freeze.dart';
import 'package:gmae_wordle/Provider/category_progress_provider.dart';
import 'package:gmae_wordle/Preferences/theme_data.dart';
import 'package:gmae_wordle/Util/firebase_options.dart';

/// ✅ Global navigator key (used by dialogs/snackbars/etc.)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Initialize essential providers before runApp
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  final wordLengthProvider = WordLengthProvider();
  await wordLengthProvider.initialize();

  final categoryProgressProvider = CategoryProgressProvider();
  await categoryProgressProvider.init();

  runApp(
    SplashWrapper(
      settingsProvider: settingsProvider,
      builder: (_) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: wordLengthProvider),
            ChangeNotifierProvider(create: (_) => StatsProvider()),
            ChangeNotifierProvider(create: (_) => DailyStatsProvider()),
            ChangeNotifierProvider(create: (_) => StreakFreezeProvider()),
            ChangeNotifierProvider.value(value: settingsProvider),
            ChangeNotifierProvider.value(
              value: categoryProgressProvider,
            ), // ✅ Added here
          ],
          child: const MyApp(),
        );
      },
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
      navigatorKey: navigatorKey,
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
