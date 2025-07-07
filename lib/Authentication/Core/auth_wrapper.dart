import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmae_wordle/Authentication/Pages/Log-in%20Page/Main/sign_in_page.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';
import 'package:gmae_wordle/Pages/Mains/Menu/menu_page.dart';
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

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user == null) {
          // 🔴 Logout Cleanup
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final statsProvider = context.read<StatsProvider>();
            statsProvider.cancelCloudListener();

            final dailyTracker = DailyWordPlayedTracker();
            dailyTracker.cancelListener();
          });

          return const LoginPage();
        }

        // 🟢 Authenticated
        return FutureBuilder(
          future: _initializeUserData(context, user),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return const MenuPage();
          },
        );
      },
    );
  }

  Future<void> _initializeUserData(BuildContext context, User user) async {
    final settingsProvider = context.read<SettingsProvider>();
    final statsProvider = context.read<StatsProvider>();
    final dailyTracker = DailyWordPlayedTracker();

    // 🟢 Run in parallel
    await Future.wait([
      settingsProvider.loadSettings(),
      statsProvider.loadStatsFromCloud(),
      dailyTracker.syncFromFirestore(user.uid),
    ]);

    // ✅ Defer listener start until after UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      statsProvider.listenToCloudStats();
      dailyTracker.listenToDailyPlayed();
    });
  }
}
