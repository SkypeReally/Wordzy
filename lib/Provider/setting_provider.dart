import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsProvider extends ChangeNotifier {
  bool isHapticEnabled = true;
  bool isSoundEnabled = true;
  bool isPhysicalKeyboardEnabled = true;
  bool isTileAnimationEnabled = true;
  bool autoStartDaily = false;
  int defaultWordLength = 5;

  String _displayName = "Player";
  String get displayName => _displayName;

  bool _applyingFromCloud = false;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _settingsStream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _settingsSubscription;

  SettingsProvider();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    isHapticEnabled = prefs.getBool('isHapticEnabled') ?? true;
    isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    isPhysicalKeyboardEnabled =
        prefs.getBool('isPhysicalKeyboardEnabled') ?? true;
    isTileAnimationEnabled = prefs.getBool('isTileAnimationEnabled') ?? true;
    autoStartDaily = prefs.getBool('autoStartDaily') ?? false;
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

    _initRealTimeSync();
  }

  void _initRealTimeSync() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isAnonymous = FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

    print("🧪 [SettingsProvider] _initRealTimeSync()");
    print("🧪 UID: $uid");
    print("🧪 Is anonymous: $isAnonymous");

    if (uid == null) {
      print("⚠️ UID is null — Firestore listener not initialized.");
      return;
    }

    _settingsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();

    _settingsSubscription = _settingsStream?.listen(
      (snapshot) {
        print("✅ Firestore snapshot received for SettingsProvider");
        final data = snapshot.data();
        print("📦 Firestore settings data: $data");

        if (data == null) {
          print("⚠️ No settings data found in Firestore for UID: $uid");
          return;
        }

        final cloud = data['settings'];
        if (cloud is Map<String, dynamic>) {
          print("📲 Applying cloud settings: $cloud");
          _applyCloudSettings(cloud);
        } else {
          print("⚠️ 'settings' field is missing or not a Map<String, dynamic>");
        }
      },
      onError: (error) {
        print("🔥 Firestore listener error in SettingsProvider: $error");
      },
    );
  }

  void cancelListener() {
    _settingsSubscription?.cancel();
    _settingsSubscription = null;
    _settingsStream = null;
  }

  Future<void> _applyCloudSettings(Map<String, dynamic> cloud) async {
    _applyingFromCloud = true;

    isHapticEnabled = cloud['isHapticEnabled'] ?? isHapticEnabled;
    isSoundEnabled = cloud['isSoundEnabled'] ?? isSoundEnabled;
    isPhysicalKeyboardEnabled =
        cloud['isPhysicalKeyboardEnabled'] ?? isPhysicalKeyboardEnabled;
    isTileAnimationEnabled =
        cloud['isTileAnimationEnabled'] ?? isTileAnimationEnabled;
    autoStartDaily = cloud['autoStartDaily'] ?? autoStartDaily;
    defaultWordLength = cloud['defaultWordLength'] ?? defaultWordLength;
    _displayName = cloud['displayName'] ?? _displayName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHapticEnabled', isHapticEnabled);
    await prefs.setBool('isSoundEnabled', isSoundEnabled);
    await prefs.setBool('isPhysicalKeyboardEnabled', isPhysicalKeyboardEnabled);
    await prefs.setBool('isTileAnimationEnabled', isTileAnimationEnabled);
    await prefs.setBool('autoStartDaily', autoStartDaily);
    await prefs.setInt('defaultWordLength', defaultWordLength);
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

  Future<void> saveToCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = {
      'isHapticEnabled': isHapticEnabled,
      'isSoundEnabled': isSoundEnabled,
      'isPhysicalKeyboardEnabled': isPhysicalKeyboardEnabled,
      'isTileAnimationEnabled': isTileAnimationEnabled,
      'autoStartDaily': autoStartDaily,
      'defaultWordLength': defaultWordLength,
      'displayName': _displayName,
    };

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'settings': data,
    }, SetOptions(merge: true));
  }

  Future<void> loadFromCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final cloud = doc.data()?['settings'];

    if (cloud is Map<String, dynamic>) {
      await _applyCloudSettings(cloud);
    }
  }
}
