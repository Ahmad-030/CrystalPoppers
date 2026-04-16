import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton audio manager — background music ONLY.
/// Music stops instantly when the app is closed/backgrounded or force-killed.
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

    // Configure audio session so the OS knows this is game music.
    // When app loses focus or is force-killed, OS releases audio automatically.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.ambient,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
      AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.game,
      ),
      androidAudioFocusGainType:
      AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: true,
    ));

    // Pause/resume on interruptions (phone calls, other apps stealing focus)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        _bgPlayer.pause();
      } else {
        if (_musicEnabled && event.type == AudioInterruptionType.pause) {
          _bgPlayer.resume();
        }
      }
    });

    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;

    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.5);

    if (_musicEnabled) await _startMusic();
  }

  Future<void> _startMusic() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
      await _bgPlayer.play(AssetSource('music.mp3'));
    } catch (_) {}
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      await _startMusic();
    } else {
      await stopImmediately();
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

  /// Stop music and release audio focus — called on pause/detach/hide.
  /// Deactivating the audio session tells the OS to fully release audio
  /// resources, which stops sound even on force-close.
  Future<void> stopImmediately() async {
    await _bgPlayer.stop();
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (_) {}
  }

  Future<void> pauseMusic() async => _bgPlayer.pause();

  Future<void> resumeMusic() async {
    if (_musicEnabled) {
      try {
        final session = await AudioSession.instance;
        await session.setActive(true);
      } catch (_) {}
      await _bgPlayer.resume();
    }
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    super.dispose();
  }
}