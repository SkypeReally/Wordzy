// lib/Service/sound_service.dart
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static bool enableSound = true;

  static final _clickPlayer = AudioPlayer();
  static final _successPlayer = AudioPlayer();
  static final _errorPlayer = AudioPlayer();

  static Future<void> playClick() async {
    if (!enableSound) return;
    await _clickPlayer.play(AssetSource('sounds/click.mp3'));
  }

  static Future<void> playSuccess() async {
    if (!enableSound) return;
    await _successPlayer.play(AssetSource('sounds/success.mp3'));
  }

  static Future<void> playError() async {
    if (!enableSound) return;
    await _errorPlayer.play(AssetSource('sounds/error.mp3'));
  }

  static Future<void> stopAll() async {
    await _clickPlayer.stop();
    await _successPlayer.stop();
    await _errorPlayer.stop();
  }

  static Future<void> dispose() async {
    await _clickPlayer.dispose();
    await _successPlayer.dispose();
    await _errorPlayer.dispose();
  }
}
