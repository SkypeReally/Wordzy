import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmae_wordle/Provider/category_progress_provider.dart';
import 'package:gmae_wordle/Provider/streak_freeze.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  /// 🔵 Google Sign-In
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user != null && user.displayName != null) {
        final name = user.displayName!.trim();
        final firstName = name.contains(' ') ? name.split(' ').first : name;

        final settings = Provider.of<SettingsProvider>(context, listen: false);
        settings.setDisplayName(firstName.isNotEmpty ? firstName : "Player");
      }

      return userCred;
    } catch (e) {
      debugPrint('⚠️ Google sign-in error: $e');
      return null;
    }
  }

  /// 🟡 Email Login
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// 🟢 Anonymous Login
  Future<UserCredential> signInAnonymously(BuildContext context) async {
    final credential = await _auth.signInAnonymously();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setDisplayName("Guest");

    return credential;
  }

  /// 🔴 Sign Out Flow
  /// 🔴 Sign Out Flow
  Future<void> signOut(BuildContext context) async {
    debugPrint("🚪 Starting sign out process...");

    await Future.delayed(Duration.zero); // context safety

    try {
      debugPrint("🔁 Cancelling Firestore listeners...");

      try {
        await Provider.of<StatsProvider>(
          context,
          listen: false,
        ).cancelCloudListener();
        debugPrint("✅ StatsProvider listener cancelled");
      } catch (e) {
        debugPrint("❌ Error cancelling StatsProvider listener: $e");
      }

      try {
        await Provider.of<SettingsProvider>(
          context,
          listen: false,
        ).cancelListener();
        debugPrint("✅ SettingsProvider listener cancelled");
      } catch (e) {
        debugPrint("❌ Error cancelling SettingsProvider listener: $e");
      }

      try {
        await Provider.of<StreakFreezeProvider>(
          context,
          listen: false,
        ).cancelListener();
        debugPrint("✅ StreakFreezeProvider listener cancelled");
      } catch (e) {
        debugPrint("❌ Error cancelling StreakFreezeProvider listener: $e");
      }

      try {
        Provider.of<WordLengthProvider>(
          context,
          listen: false,
        ).cancelListener();
        debugPrint("✅ WordLengthProvider listener cancelled");
      } catch (e) {
        debugPrint("❌ Error cancelling WordLengthProvider listener: $e");
      }

      try {
        DailyWordPlayedTracker().cancelListener();
        debugPrint("✅ DailyWordPlayedTracker listener cancelled");
      } catch (e) {
        debugPrint("❌ Error cancelling DailyWordPlayedTracker listener: $e");
      }

      try {
        await Provider.of<CategoryProgressProvider>(
          context,
          listen: false,
        ).resetLocalOnly(); // ✅ Do NOT use resetAll()
        debugPrint("✅ CategoryProgressProvider local cache cleared");
      } catch (e) {
        debugPrint("❌ Error clearing CategoryProgressProvider local cache: $e");
      }

      // 🔐 Firebase Sign Out
      try {
        debugPrint("🔐 Signing out from Firebase...");
        await _auth.signOut();
        debugPrint("✅ Firebase sign out complete");
      } catch (e) {
        debugPrint("❌ Firebase sign-out error: $e");
      }

      // 🔐 Google Sign Out
      try {
        debugPrint("🔐 Signing out from Google...");
        await _googleSignIn.signOut();
        debugPrint("✅ Google sign out complete");
      } catch (e) {
        debugPrint("❌ Google sign-out error: $e");
      }

      debugPrint("🚪 Sign out process completed successfully");
    } catch (e) {
      debugPrint("⚠️ Sign out flow error: $e");
    }
  }

  /// 🔁 Firebase Auth state listener
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
