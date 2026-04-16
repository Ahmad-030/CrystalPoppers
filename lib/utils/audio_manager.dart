import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton audio manager — background music ONLY.
/// All SFX removed. Music stops instantly when the app is closed/backgrounded.
class AudioManager extends ChangeNotifier {
  AudioManager._internal();
  static final AudioManager instance = AudioManager._internal();
  factory AudioManager() => instance;

  final AudioPlayer _bgPlayer = AudioPlayer();

  bool _musicEnabled = true;
  bool _initialized = false;

  bool get musicEnabled => _musicEnabled;

  // SFX flag kept as stub so existing references compile (does nothing)
  bool get sfxEnabled => false;

  /// Call once from main() before runApp.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;

    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.5);

    if (_musicEnabled) await _startMusic();
  }

  Future<void> _startMusic() async {
    try {
      await _bgPlayer.play(AssetSource('music.mp3'));
    } catch (_) {}
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      await _startMusic();
    } else {
      await _bgPlayer.stop();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', _musicEnabled);
    notifyListeners();
  }

  // Stub — SFX removed
  Future<void> toggleSfx() async {}
  Future<void> playPop() async {}
  Future<void> playSwap() async {}
  Future<void> playWin() async {}
  Future<void> playLose() async {}
  Future<void> playPower() async {}

  /// Stop music instantly — call from AppLifecycleListener on pause/detach.
  Future<void> stopImmediately() async {
    await _bgPlayer.stop();
  }

  Future<void> pauseMusic() async => _bgPlayer.pause();

  Future<void> resumeMusic() async {
    if (_musicEnabled) await _bgPlayer.resume();
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    super.dispose();
  }
}