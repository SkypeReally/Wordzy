import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Main/sign_in_page.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';
import 'package:gmae_wordle/Navigation/main_navigation.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';

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

        // ❌ User not signed in or is anonymous → show LoginPage
        if (user == null) {
          // 🔴 Cleanup on logout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final statsProvider = context.read<StatsProvider>();
            statsProvider.cancelCloudListener();

            final dailyTracker = DailyWordPlayedTracker();
            dailyTracker.cancelListener();
          });

          return const LoginPage();
        }

        // ✅ Fully signed-in user → initialize data and show MainNavigation
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
    final dailyTracker = DailyWordPlayedTracker();

    // 🧩 Load all data in parallel
    await Future.wait([
      settingsProvider.loadSettings(),
      statsProvider.loadStatsFromCloud(),
      dailyTracker.syncFromFirestore(user.uid),
    ]);

    // 🎧 Start real-time listeners after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      statsProvider.listenToCloudStats();
      dailyTracker.listenToDailyPlayed();
    });
  }
}
