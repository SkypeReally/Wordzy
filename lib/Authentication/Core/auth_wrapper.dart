import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Main/sign_in_page.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';
import 'package:gmae_wordle/Navigation/main_navigation.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/category_progress_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        debugPrint(
          "👤 AuthWrapper: user = ${user?.uid}, isAnonymous = ${user?.isAnonymous}",
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<StatsProvider>().cancelCloudListener();
            DailyWordPlayedTracker().cancelListener();
          });

          return const LoginPage();
        }

        return FutureBuilder(
          future: _initializeUserData(context, user),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return const MainNavigationPage();
          },
        );
      },
    );
  }

  Future<void> _initializeUserData(BuildContext context, User user) async {
    final settingsProvider = context.read<SettingsProvider>();
    final statsProvider = context.read<StatsProvider>();
    final categoryProgressProvider = context.read<CategoryProgressProvider>();
    final dailyTracker = DailyWordPlayedTracker();

    await Future.wait([
      settingsProvider.loadSettings(),
      statsProvider.loadStatsFromCloud(),
      categoryProgressProvider.init(),
      dailyTracker.syncFromFirestore(user.uid),
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      statsProvider.listenToCloudStats();
      dailyTracker.listenToDailyPlayed();
    });
  }
}
