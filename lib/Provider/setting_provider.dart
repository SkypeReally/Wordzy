import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gmae_wordle/Provider/wordlength_provider.dart';
import 'package:gmae_wordle/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsProvider extends ChangeNotifier {
  bool isHapticEnabled = true;
  bool isSoundEnabled = true;
  bool isPhysicalKeyboardEnabled = true;
  bool isTileAnimationEnabled = true;
  bool autoStartDaily = false;
  bool hardMode = false;
  bool hintsEnabled = false;

  int defaultWordLength = 5;

  String _displayName = "Player";
  String get displayName => _displayName;

  bool _applyingFromCloud = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _settingsSubscription;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  SettingsProvider();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    hintsEnabled = prefs.getBool('hintsEnabled') ?? false;
    isHapticEnabled = prefs.getBool('isHapticEnabled') ?? true;
    isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    isPhysicalKeyboardEnabled =
        prefs.getBool('isPhysicalKeyboardEnabled') ?? true;
    isTileAnimationEnabled = prefs.getBool('isTileAnimationEnabled') ?? true;
    autoStartDaily = prefs.getBool('autoStartDaily') ?? false;
    hardMode = prefs.getBool('hardMode') ?? false;
    defaultWordLength = prefs.getInt('defaultWordLength') ?? 5;

    final savedName = prefs.getString('displayName');
    if (savedName != null && savedName.trim().isNotEmpty) {
      _displayName = savedName.trim();
    } else {
      final user = FirebaseAuth.instance.currentUser;
      final firebaseName = user?.displayName;
      _displayName = firebaseName?.trim().split(" ").first ?? "Player";
    }

    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      debugPrint("🟢 [SettingsProvider] Loading settings from Firestore...");
      await _loadFromCloudOnce();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initRealTimeSync();
      });
    } else {
      debugPrint(
        "⚠️ [SettingsProvider] Skipping Firestore sync for anonymous or null user.",
      );
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _loadFromCloudOnce() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final cloud = doc.data()?['settings'];
      if (cloud is Map<String, dynamic>) {
        await _applyCloudSettings(cloud);
        debugPrint("☁️ [SettingsProvider] Initial cloud settings loaded.");
      }
    } catch (e) {
      debugPrint(
        "🔥 [SettingsProvider] Error loading settings from Firestore: $e",
      );
    }
  }

  void _initRealTimeSync() {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null || user!.isAnonymous) {
      debugPrint(
        "⚠️ [SettingsProvider] Listener not initialized — UID is null or anonymous.",
      );
      return;
    }

    debugPrint(
      "📡 [SettingsProvider] Setting up Firestore listener for settings...",
    );

    _settingsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (snapshot) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null || currentUser.isAnonymous) {
              debugPrint(
                "⛔ [SettingsProvider] User signed out or anonymous — skipping snapshot.",
              );
              return;
            }

            final data = snapshot.data();
            final cloud = data?['settings'];
            if (cloud is Map<String, dynamic>) {
              debugPrint(
                "📲 [SettingsProvider] Applying cloud settings update: $cloud",
              );
              _applyCloudSettings(cloud);
            } else {
              debugPrint(
                "⚠️ [SettingsProvider] 'settings' field missing or malformed.",
              );
            }
          },
          onError: (error) {
            debugPrint(
              "🔥 [SettingsProvider] Firestore listener error: $error",
            );
          },
          cancelOnError: true,
        );
  }

  Future<void> cancelListener() async {
    await _settingsSubscription?.cancel();
    _settingsSubscription = null;
    debugPrint("🔕 Firestore listener cancelled in SettingsProvider.");
  }

  Future<void> _applyCloudSettings(Map<String, dynamic> cloud) async {
    _applyingFromCloud = true;
    debugPrint("☁️ [SettingsProvider] Applying cloud settings...");

    if (cloud.containsKey('isHapticEnabled')) {
      isHapticEnabled = cloud['isHapticEnabled'];
    }
    if (cloud.containsKey('isSoundEnabled')) {
      isSoundEnabled = cloud['isSoundEnabled'];
    }
    if (cloud.containsKey('isPhysicalKeyboardEnabled')) {
      isPhysicalKeyboardEnabled = cloud['isPhysicalKeyboardEnabled'];
    }
    if (cloud.containsKey('isTileAnimationEnabled')) {
      isTileAnimationEnabled = cloud['isTileAnimationEnabled'];
    }
    if (cloud.containsKey('autoStartDaily')) {
      autoStartDaily = cloud['autoStartDaily'];
    }
    if (cloud.containsKey('hardMode')) {
      hardMode = cloud['hardMode'];
    }
    if (cloud.containsKey('defaultWordLength')) {
      final newLength = cloud['defaultWordLength'];
      if (defaultWordLength != newLength) {
        defaultWordLength = newLength;

        final context = navigatorKey.currentContext;
        if (context != null) {
          try {
            final wordLengthProvider = context.read<WordLengthProvider>();
            wordLengthProvider.setWordLength(defaultWordLength);
            debugPrint(
              "🔁 [SettingsProvider] WordLengthProvider synced to $defaultWordLength from cloud.",
            );
          } catch (e) {
            debugPrint(
              "⚠️ [SettingsProvider] Failed to update WordLengthProvider: $e",
            );
          }
        }
      }
    }

    if (cloud.containsKey('hintsEnabled')) {
      hintsEnabled = cloud['hintsEnabled'];
    }

    if (cloud.containsKey('displayName')) {
      _displayName = cloud['displayName'];
    } else {
      final user = FirebaseAuth.instance.currentUser;
      _displayName = user?.displayName?.split(" ").first ?? "Player";
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHapticEnabled', isHapticEnabled);
    await prefs.setBool('isSoundEnabled', isSoundEnabled);
    await prefs.setBool('isPhysicalKeyboardEnabled', isPhysicalKeyboardEnabled);
    await prefs.setBool('isTileAnimationEnabled', isTileAnimationEnabled);
    await prefs.setBool('autoStartDaily', autoStartDaily);
    await prefs.setBool('hardMode', hardMode);
    await prefs.setInt('defaultWordLength', defaultWordLength);
    await prefs.setBool('hintsEnabled', hintsEnabled);
    await prefs.setString('displayName', _displayName);

    notifyListeners();
    _applyingFromCloud = false;
  }

  Future<void> _save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }

    if (!_applyingFromCloud) {
      await saveToCloud();
    }
  }

  void setDisplayName(String name) {
    _displayName = name.trim().isEmpty ? "Player" : name.trim();
    _save('displayName', _displayName);
    notifyListeners();
  }

  void toggleHaptic(bool val) {
    isHapticEnabled = val;
    _save('isHapticEnabled', val);
    notifyListeners();
  }

  void toggleSound(bool val) {
    isSoundEnabled = val;
    _save('isSoundEnabled', val);
    notifyListeners();
  }

  void togglePhysicalKeyboard(bool val) {
    isPhysicalKeyboardEnabled = val;
    _save('isPhysicalKeyboardEnabled', val);
    notifyListeners();
  }

  void toggleTileAnimation(bool val) {
    isTileAnimationEnabled = val;
    _save('isTileAnimationEnabled', val);
    notifyListeners();
  }

  void toggleAutoStartDaily(bool val) {
    autoStartDaily = val;
    _save('autoStartDaily', val);
    notifyListeners();
  }

  void setDefaultWordLength(int val) {
    defaultWordLength = val;
    _save('defaultWordLength', val);
    notifyListeners();
  }

  void setHardMode(bool val) {
    hardMode = val;
    _save('hardMode', val);
    notifyListeners();
  }

  void setHintsEnabled(bool val) {
    hintsEnabled = val;
    _save('hintsEnabled', val);
    notifyListeners();
  }

  Future<void> saveToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      debugPrint(
        "⚠️ [SettingsProvider] Skipping cloud save — user is null or anonymous.",
      );
      return;
    }

    final data = {
      'isHapticEnabled': isHapticEnabled,
      'isSoundEnabled': isSoundEnabled,
      'isPhysicalKeyboardEnabled': isPhysicalKeyboardEnabled,
      'isTileAnimationEnabled': isTileAnimationEnabled,
      'autoStartDaily': autoStartDaily,
      'hardMode': hardMode,
      'defaultWordLength': defaultWordLength,
      'displayName': _displayName,
      'hintsEnabled': hintsEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'settings': data,
    }, SetOptions(merge: true));

    debugPrint("☁️ [SettingsProvider] Settings saved to Firestore.");
  }

  @override
  void dispose() {
    cancelListener();
    super.dispose();
  }
}
