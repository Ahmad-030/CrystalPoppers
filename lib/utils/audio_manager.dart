import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton audio manager.
/// Background music loops via audioplayers. SFX use one-shot players.
/// Music state persists across sessions via SharedPreferences.
class AudioManager extends ChangeNotifier {
  AudioManager._internal();
  static final AudioManager instance = AudioManager._internal();
  factory AudioManager() => instance;

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _initialized = false;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  /// Call once from main() before runApp.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _sfxEnabled = prefs.getBool('sfxEnabled') ?? true;

    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.45);
    await _sfxPlayer.setVolume(0.8);

    if (_musicEnabled) await _startMusic();
  }

  Future<void> _startMusic() async {
    try {
      // Tries to load bundled asset; gracefully silences if file not present.
      await _bgPlayer.play(AssetSource('audio/bg_music.mp3'));
    } catch (_) {
      // Asset not bundled yet — no crash.
    }
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      await _startMusic();
    } else {
      await _bgPlayer.pause();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', _musicEnabled);
    notifyListeners();
  }

  Future<void> toggleSfx() async {
    _sfxEnabled = !_sfxEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfxEnabled', _sfxEnabled);
    notifyListeners();
  }

  Future<void> playPop() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/pop.mp3'));
    } catch (_) {}
  }

  Future<void> playSwap() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/swap.mp3'));
    } catch (_) {}
  }

  Future<void> playWin() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/win.mp3'));
    } catch (_) {}
  }

  Future<void> playLose() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/lose.mp3'));
    } catch (_) {}
  }

  Future<void> playPower() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/power.mp3'));
    } catch (_) {}
  }

  Future<void> pauseMusic() async => _bgPlayer.pause();
  Future<void> resumeMusic() async {
    if (_musicEnabled) await _bgPlayer.resume();
  }

  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
