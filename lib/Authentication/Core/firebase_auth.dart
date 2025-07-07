import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gmae_wordle/Provider/setting_provider.dart';
import 'package:gmae_wordle/Provider/statsprovider.dart';
import 'package:gmae_wordle/Daily%20Word/dialyword_tracker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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
      print('Google sign-in error: $e');
      return null;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInAnonymously(BuildContext context) async {
    final credential = await _auth.signInAnonymously();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setDisplayName("Guest");
    return credential;
  }

  /// 🔐 Complete logout flow with proper cleanup
  Future<void> signOut(BuildContext context) async {
    try {
      // ✅ Cancel all listeners
      Provider.of<StatsProvider>(context, listen: false).cancelCloudListener();
      DailyWordPlayedTracker().cancelListener(); // now actually works

      // ✅ Sign out
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
